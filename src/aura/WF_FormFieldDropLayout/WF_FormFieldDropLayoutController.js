/**
 * Created by afaf.awad on 10/6/2021.
 */

({
    doInit : function (cmp,event,helper){
        // console.log('doInit formFieldDropLayout...');
        let dropFields = cmp.get('v.dropFields');
        dropFields.forEach(f => {
            f.Field_Type__c = f.Field_Type__c.replace('mtd_','');
        });
        cmp.set('v.dropFields', dropFields);
        },

    startDragSort : function (cmp,event,helper) {
        let target = event.target;
        console.log('target == ' + !target.title);
        event.dataTransfer.setData('Text', target.id);
        event.dataTransfer.setData('Title', target.title);
        cmp.set('v.dragCategory', cmp.get('v.sectionCategory'));
        cmp.set('v.isDraggable', target.title == 'true' ? false : true);
    },

    dragOver : function (cmp,event,helper) {
        event.preventDefault();
    },

    allowDrop: function (cmp, event, helper) {
        event.preventDefault();
        let targetId = event.dataTransfer.getData("text");
        let targetName = event.dataTransfer.getData("Title")

        let category = cmp.get('v.dragCategory');
        let divSection = cmp.get('v.sectionCategory');

        console.log('target dropping == ' + JSON.stringify(targetName));  // <<== Pulling in title
        console.log('divSection == ' + divSection);

        if(category == divSection) {
            helper.updateLists(cmp, targetId, event.clientY);
        }
        cmp.set('v.isDraggable', true);
    },

    editField : function (cmp,event,helper){
        console.log('editing field');
        let clickedValue = event.getSource().get('v.value');
        cmp.set("v.fieldDialogModal", []);

        console.log('clickedValue == ' + JSON.stringify(clickedValue));
        console.log('Survey == ' + JSON.stringify(cmp.get('v.survey')));

        $A.createComponent(
            "c:WF_FormFieldEditModal",
            {
                "fieldDetails": clickedValue,
                "survey" : cmp.get('v.survey'),
                "aura:id": 'fieldDialogModal'
            },
            function (actionCmp, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    let cmpInput = cmp.get("v.fieldDialogModal");
                    cmpInput.push(actionCmp);
                    cmp.set("v.fieldDialogModal", cmpInput);
                } else if (status === "INCOMPLETE") {
                    console.log("Could not create component: No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Could not create component: Error - " + errorMessage);
                }
            });
    },

    removeField : function(cmp,event,helper){
        let clickedValue = event.getSource().get('v.value');
        let fieldList = cmp.get('v.fieldOptions');
        let dropList = cmp.get('v.dropFields');

        console.log('clicked == ' + JSON.stringify(clickedValue));

        let removeField;
        for (let i = 0; i < dropList.length; i++) {
            if (dropList[i].dragId == clickedValue.dragId) {
               removeField = dropList[i];
               if(removeField.sqId) {
                   helper.deleteRecord(cmp, removeField.sqId);
                   delete removeField.sqId; //remove sqId
               }
                dropList.splice(i, 1);
            }
        }

        console.log('droplist == ' + dropList.length);
        cmp.set('v.dropFields', dropList);

        //call parent (WF_FormFieldContainer) to add fields back to their fieldOptions list,
        // because body fields are broken out into 3 sections.
        if(removeField.isUnique__c) {
            fieldList.push(removeField);
            let appEvent = $A.get("e.c:WF_AppEvent");
            appEvent.setParams({
                'removeField': removeField
            });
            appEvent.fire();
            console.log('updating fieldOptions == ' + JSON.stringify(fieldList));
            cmp.set('v.fieldOptions', fieldList);
        }

    },

    handleModalEvent : function(cmp,event,helper){
        let field = event.getParam('field');
        // console.log('modal field == ' + JSON.stringify(field));
        if(field) {
            let dropfieldList = cmp.get('v.dropFields');
            let dropFieldIndex = dropfieldList.findIndex(f => f.dragId == field.dragId);
            console.log('matched dropfield index == ' + dropFieldIndex);
            if(dropFieldIndex >= 0) {
                console.log('matched Field == ' + JSON.stringify(field));
                dropfieldList.splice(dropFieldIndex, 1);
                //updating dragId here in order to find original match first, THEN update with metaId + recordId
                field.dragId = field.dragId.length > 18 ? field.dragId : field.Id + field.sqId;
                dropfieldList.splice(dropFieldIndex, 0, field);
                cmp.set('v.dropFields', dropfieldList);
            }
        }
    },
});