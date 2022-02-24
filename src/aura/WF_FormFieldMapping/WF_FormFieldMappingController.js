/**
 * Created by afaf.awad on 10/20/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit field mapping...');
        cmp.set("v.isLoading", true);
        cmp.set('v.recordId', helper.getSurveyId(cmp));
        let action = cmp.get("c.getSurveyQuestionInfo");
        action.setParams({
            surveyId: cmp.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    console.log('returned data == ' + JSON.stringify(data));
                    cmp.set('v.formFieldData', data);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: WF_FormFieldMapping');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - WF_FormFieldMapping: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in WF_FormFieldMapping");
                }
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    handleOperation : function (cmp, event, helper) {
        let clickedValue = event.getSource().get('v.value');
        let formData = cmp.get('v.formFieldData');
        formData.forEach(f => {
            if(f.sqRecord.Id === clickedValue.sqRecord.Id){
                f.sqRecord.Overwrite__c = !f.sqRecord.Overwrite__c;
            }
        })
        cmp.set('v.formFieldData', formData);
    },

    handleSave : function(cmp,event,helper){
        console.log('saving survey questions....');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        cmp.set("v.nextStepId", stepId);
        cmp.set("v.nextCmpName", cmpName);
        cmp.set("v.isLoading", true);

        let sqRecords = [];
        let formFieldData = cmp.get('v.formFieldData');
        formFieldData.forEach(f => {
            let sq = {};
            sq.Id = f.sqRecord.Id;
            sq.Overwrite = f.sqRecord.Overwrite__c;
            sqRecords.push(sq);
        })

        if(sqRecords.length > 0) {
            helper.saveRecord(cmp, sqRecords);
        }else{
            helper.handleSuccess(cmp);
        }
    },

});