/**
 * Created by afaf.awad on 10/20/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('doInit Survey Form...');
        cmp.set("v.isLoading", true);
        cmp.set('v.recordId', helper.getSurveyId(cmp));
        cmp.set("v.isLoading", false);
        // let action = cmp.get("c.getSurveyInfo");
        // action.setParams({
        //     surveyId: cmp.get('v.recordId'),
        //     stepId: cmp.get('v.stepId')
        // });
        // action.setCallback(this, function (response) {
        //     let state = response.getState();
        //     if (state === "SUCCESS") {
        //         let data = response.getReturnValue();
        //         if (data) {
        //             console.log('Survey Data == ' + JSON.stringify(data));
        //         }
        //     } else if (state === "INCOMPLETE") {
        //         console.log('Incomplete: WF_FormInfo');
        //     } else if (state === "ERROR") {
        //         let errors = response.getError();
        //         if (errors) {
        //             if (errors[0] && errors[0].message) {
        //                 console.log("Error message - WF_FormInfo: " +
        //                     errors[0].message);
        //             }
        //         } else {
        //             console.log("Unknown error in WF_FormInfo");
        //         }
        //     }
        //     cmp.set("v.isLoading", false);
        // });
        // $A.enqueueAction(action);
    },


    handleOnLoad: function (cmp, event, helper) {
        helper.showHideDate(cmp);
    },

    publishTypeChange : function(cmp,event,helper){
        helper.showHideDate(cmp);
    },

    handleSave: function (cmp, event, helper) {
        console.log('saving record....');
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        // if (helper.validate(cmp)) {
            cmp.set("v.isLoading", true);
            cmp.find('publishingForm').submit();
        // }
    },

    handleSuccess: function (cmp, event, helper) {
        // console.log('handleSuccess...');
        cmp.set("v.isLoading", true);

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