/**
 * Created by afaf.awad on 5/26/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('dimTags cmp doInit...');
        let action = cmp.get("c.getDimTags");
        action.setParams({
            'recordId' : cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log(JSON.stringify(data));
                let itemObj = item => {
                    return {
                        type: 'icon',
                        iconName: 'standard:' + cmp.get('v.sobjecttype').toLowerCase(),
                        label: item.dimTag.Label,
                        name: item.dimTag.Id,
                        deleteRequest: item.deleteRequest,
                        alternativeText: item.dimTag.Label,
                        convertedTag: !item.convertedTag ? null :
                            {
                                type: 'icon',
                                iconName: 'standard:' + cmp.get('v.sobjecttype').toLowerCase(),
                                label: item.convertedTag.Label,
                                name: item.convertedTag.Id,
                                alternativeText: item.convertedTag.Label,

                            }
                    }
                }

                let systemTags = [];
                let publicTags = [];
                let privateTags = [];
                data.forEach((tag) => {
                    switch(tag.dimTag.Visibility__c){
                        case 'System':
                            systemTags.push(itemObj(tag));
                            break;
                        case 'Public':
                            publicTags.push(itemObj(tag));
                            break;
                        case 'Private':
                            privateTags.push(itemObj(tag));
                            break;
                    }
                })

                cmp.set('v.allSelected', true);
                cmp.set('v.hideFlagSelected', false);
                cmp.set('v.systemTags', systemTags);
                cmp.set('v.publicTags', publicTags);
                cmp.set('v.privateTags', privateTags);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleSectionToggle: function (cmp, event) {
        let openSections = event.getParam('openSections');

        if (openSections.length === 0) {
            cmp.set('v.activeSectionsMessage', "All sections are closed");
        } else {
            cmp.set('v.activeSectionsMessage', "Open sections: " + openSections.join(', '));
        }
    },

    launchTagManager : function(cmp,event,helper){
        $A.get("e.force:navigateToURL").setParams({
            "url": "/lightning/app/c__Tag_Manager"
        }).fire();

    },

    hideFlags : function (cmp,event,helper){
        //unclick all button
        cmp.set('v.hideFlagSelected', true);
        cmp.set('v.allSelected', false);
        //get all 3 lists
        let systemTags = cmp.get('v.systemTags');
        let publicTags = cmp.get('v.publicTags');
        let privateTags = cmp.get('v.privateTags');

        let tagList = tags => {
            let newTagList =[];
            tags.forEach((tag) => {
                if(tag.deleteRequest == false){
                    newTagList.push(tag);
                }
            })

            return newTagList;
        }


        let fSystemTags = tagList(systemTags);
        let fPublicTags = tagList(publicTags);
        let fPrivateTags = tagList(privateTags);

        cmp.set('v.systemTags', fSystemTags);
        cmp.set('v.publicTags', fPublicTags);
        cmp.set('v.privateTags', fPrivateTags);
    },

    allTags : function (cmp,event,helper){

    }
});