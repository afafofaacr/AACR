/**
 * Created by afaf.awad on 9/29/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit Form Fields...');
        cmp.set("v.isLoading", true);
        cmp.set('v.recordId', helper.getSurveyId(cmp));
        let action = cmp.get("c.getFormFieldInfo");
        action.setParams({
            surveyId: cmp.get('v.recordId'),
            stepId : cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    // console.log('Survey Data == ' + JSON.stringify(data.sqMetadataMap));
                    //Set Field Options
                    cmp.set('v.PerInfoFields', helper.sortFields(data.piFields));
                    cmp.set('v.SciIntFields', helper.sortFields(data.sciFields));
                    cmp.set('v.CustomFields', helper.sortFields(data.customFields));
                    cmp.set('v.HeaderFields', helper.sortFields(data.headerFields));
                    cmp.set('v.FooterFields', helper.sortFields(data.footerFields));
                    cmp.set('v.survey', data.survey);

                    if(Object.keys(data.sqMetadataMap).length > 0 && data.sqMetadataMap.constructor === Object){
                        console.log('Setting up saved fields');
                        helper.setUpLayout(cmp,data.sqMetadataMap, data.sqRecordsMap, 'v.PerInfoFields', 'v.bodyDropFields');
                        helper.setUpLayout(cmp,data.sqMetadataMap, data.sqRecordsMap,'v.SciIntFields', 'v.bodyDropFields');
                        helper.setUpLayout(cmp,data.sqMetadataMap, data.sqRecordsMap,'v.CustomFields', 'v.bodyDropFields');
                        helper.setUpLayout(cmp,data.sqMetadataMap, data.sqRecordsMap,'v.HeaderFields', 'v.headerDropFields');
                        helper.setUpLayout(cmp,data.sqMetadataMap, data.sqRecordsMap,'v.FooterFields', 'v.footerDropFields');
                        helper.orderSavedFields(cmp);
                    }else if(data.survey.Form_Type__c == 'MS'){
                        helper.setUpLockedFields(cmp);
                    }
                    let allBodyFields = cmp.get('v.PerInfoFields').concat(cmp.get('v.SciIntFields'), cmp.get('v.CustomFields')); //merge arrays into body section list
                    // allBodyFields = helper.orderSavedFields(cmp,allBodyFields);
                    cmp.set('v.allBodyFields', allBodyFields);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: WF_FormInfo');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - WF_FormInfo: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in WF_FormInfo");
                }
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },


    handleDragDropEvent : function(cmp,event,helper){
        let fieldCategory = event.getParam("fieldCategory");
        let removeField = event.getParam("removeField");
        let fieldElement = event.getParam("fieldElement");

        console.log('fieldCategory == ' + fieldCategory);
        console.log('removeField == ' + JSON.stringify(removeField));
        console.log('fieldElement == ' + JSON.stringify(fieldElement));

        if(fieldCategory) {
            console.log('updating dragCategory');
            cmp.set('v.dragCategory', fieldCategory);
        }

        // //Event to add list back into field list after its been removed
        if(removeField){
            console.log('Adding removed field from droplist to fieldlist');
            let list = 'v.' + removeField.Layout_Section__c + 'Fields';
            let cmpList = cmp.get(list);
            console.log('list = ' + list);
            // console.log('get cmp = ' + JSON.stringify(cmpList));
            console.log('new list = ' + JSON.stringify(cmpList.concat([removeField])));
            cmp.set(list, cmpList.concat([removeField]));
        }


        //Event to remove fields from field list when field is dragged into dropzone
        if(fieldElement){
            let fieldList = 'v.' + fieldElement.Layout_Section__c + 'Fields';
            let fieldListCmp = cmp.get(fieldList);
            let index = fieldListCmp.findIndex(bfs => bfs.dragId == fieldElement.dragId);
            fieldListCmp.splice(index, 1);
            cmp.set(fieldList, fieldListCmp);
        }
    },

    handleSave : function(cmp,event,helper){
        console.log('saving survey questions....');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        cmp.set("v.nextStepId", stepId);
        cmp.set("v.nextCmpName", cmpName);
        cmp.set("v.isLoading", true);


        let orderFieldList = (cmpList, orderNum) =>
        {
            let dropList = cmp.get(cmpList);
            dropList.forEach(f => {
                f.orderNumber = orderNum;
                orderNum = orderNum + 1;
            })
            console.log('ordernumber == ' + orderNum);

            return {dropList : dropList, orderNum : orderNum};
        }

        let fieldsToSave = [];
        let orderFields = orderFieldList('v.headerDropFields',1);
        fieldsToSave.push(...orderFields.dropList);
        orderFields = orderFieldList('v.bodyDropFields',orderFields.orderNum);
        fieldsToSave.push(...orderFields.dropList);
        orderFields = orderFieldList('v.footerDropFields',orderFields.orderNum);
        fieldsToSave.push(...orderFields.dropList);

        // console.log('fieldsToSave == ' + JSON.stringify(fieldsToSave));

        if(fieldsToSave.length > 0) {
            helper.saveRecord(cmp, fieldsToSave);
        }else{
            helper.handleSuccess(cmp);
        }

    },
});