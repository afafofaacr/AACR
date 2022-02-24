/**
 * Created by afaf.awad on 11/5/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit surveyForm...');
        cmp.set("v.isLoading", true);
        cmp.set('v.recordId', helper.getSurveyId(cmp));
        let action = cmp.get("c.getFormInfo");
        action.setParams({
            surveyId: cmp.get('v.recordId'),
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    // console.log('Survey Data == ' + JSON.stringify(data));

                    data.bodyFields.forEach(f => {
                        f.input = f.Field_Type__c == 'checkbox' ? false : '';
                    })
                    cmp.set('v.formFields', data.bodyFields);
                    cmp.set('v.survey', data.survey);
                    cmp.set('v.communitySite', data.siteUrl);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: WF_FormSurvey');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - WF_FormSurvey: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in WF_FormSurvey");
                }
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    saveRecord: function (cmp, event, helper) {
        if(helper.validate(cmp)){
            console.log('VALIDATED!!');
            let action = cmp.get("c.saveFormResponses");
            action.setParams({
                surveyId: cmp.get('v.recordId'),
                inputListJSON : JSON.stringify(helper.getInputFields(cmp))
            });

            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let data = response.getReturnValue();
                    console.log('Responses Saved!');
                    cmp.set('v.isCompleted', true);
                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete: saveRecord');
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message - saveRecord: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error in saveRecord");
                    }
                }
                cmp.set("v.isLoading", false);
            });
            $A.enqueueAction(action);
        }

    }
});