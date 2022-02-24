/**
 * Created by afaf.awad on 6/4/2021.
 */

({

    doInit: function(cmp,event,helper){
        console.log('doInit...' + JSON.stringify(cmp.get('v.objectFilters')));
        cmp.set('v.columns', [
            {label: 'Tag', fieldName: 'link', type: 'button', sortable: true,
                typeAttributes: {label: { fieldName: 'tagName' }, variant: 'base', sortable: true}},
            {label: 'Type', fieldName: 'objectName', type: 'text', sortable: true},
            {label: 'Tagged', fieldName: 'tagCount', type: 'integer', sortable: true}
        ]);
        let action = cmp.get("c.getDimTagInfo");
        action.setParams({
           'tagLevel' : cmp.get('v.tagLevel'),
            'filterString' : JSON.stringify(cmp.get('v.objectFilters')),
            'searchString' : cmp.get('v.searchString')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('returned Data = ' + JSON.stringify(data));
                cmp.set('v.dimTagData', data);
                cmp.set('v.isLoading', false);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
                cmp.set('v.isLoading', false);
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " + cmp.get('v.tagLevel') + ' ' +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
                cmp.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    goToSubTab : function(component, event, helper) {
        var row = event.getParam('row');
        console.log('row = ' + JSON.stringify(row));
        let workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__DimensionTagDetails" ,
                },
                "state": {
                    "c__dimTagId" : row.dtId,
                    "c__objectName" : row.objectName
                }
            },
            //TODO: fix tab on refresh. May need to set the tab name on details cmp
            focus: true
        }).then(function(response) {
            console.log(response);
            workspaceAPI.setTabLabel({
                tabId: response,
                label: ' ' + row.tagName + ' Details'
            });
            workspaceAPI.setTabIcon({
                    tabId: response,
                    icon: "action:new_task",
                    iconAlt: "Tag List Details"
            });
        }).catch(function(error) {
            console.log(error);
        });
    },

    handleSort : function (cmp,event,helper){
        let fieldName = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');
        console.log('fieldName to Sort : ' + fieldName);
        console.log('sortedDirection = ' + sortDirection);
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },

});