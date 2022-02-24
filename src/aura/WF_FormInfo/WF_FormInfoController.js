/**
 * Created by afaf.awad on 9/28/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit Survey Form...');
        cmp.set("v.isLoading", true);
        cmp.set('v.recordId', helper.getSurveyId(cmp));
        let action = cmp.get("c.getSurveyInfo");
        action.setParams({
            surveyId: cmp.get('v.recordId'),
            stepId : cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    console.log('Survey Data == ' + JSON.stringify(data));
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

    handleOnLoad : function (cmp,event,helper){
        if(cmp.get('v.recordId') == null){
            cmp.set('v.disableSystemTag', false);
        }else{
            let sysTag = cmp.find('systemTagRO').get('v.value');
            cmp.find('systemTag').set('v.value', sysTag);
        }

    },

    updateSystemTag : function (cmp,event,helper){
        let formtype = cmp.find('formType').get('v.value');
        console.log('formType = ' + formtype);
        if(formtype) {
            let formName = cmp.find('Name').get('v.value');
            cmp.find('systemTag').set('v.value', formtype + '_' + formName.replaceAll(' ', '_'));
        }
    },

    handleSave : function(cmp,event,helper){
        console.log('saving record....');
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        if(helper.validate(cmp)) {
            cmp.set("v.isLoading", true);

            var sysTag = cmp.find('systemTag').get('v.value');
            cmp.find('systemTagRO').set('v.value', sysTag);
            cmp.find('surveyForm').submit();
            // var isSuccess = helper.saveRecord(cmp);
            //
            // if (isSuccess) {
            //     helper.handleSuccess(cmp);
            // } else {
            //     helper.handleError(cmp);
            // }
        }
    },

    handleSuccess: function (cmp, event, helper) {
        // console.log('handleSuccess...');
        cmp.set("v.isLoading", true);
        let params = event.getParams();
        console.log('recordId: ' + params.response.id);
        helper.addSurveyIdToURL(cmp, params.response.id);
        helper.addEmbeddedCode(cmp,params.response.id);

        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();

    },

    handleError: function (cmp, event, helper) {
        cmp.set("v.isLoading", false);
        var errors = event.getParams();
        console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.nextStepId");
        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },
});