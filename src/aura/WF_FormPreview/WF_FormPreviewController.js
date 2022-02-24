/**
 * Created by afaf.awad on 10/29/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit Preview...');
        console.log('record == ' + cmp.get('v.recordId'));
        cmp.set("v.isLoading", true);
        if(!cmp.get('v.recordId')) {
            cmp.set('v.recordId', helper.getSurveyId(cmp));
        }

        let action = cmp.get("c.getFormInfo");
        action.setParams({
            surveyId: cmp.get('v.recordId'),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    console.log('Survey Data == ' + JSON.stringify(data));
                    cmp.set('v.formFields', data.bodyFields);
                    cmp.set('v.survey', data.survey);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: WF_FormPreview');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - WF_FormPreview: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in WF_FormPreview");
                }
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
});