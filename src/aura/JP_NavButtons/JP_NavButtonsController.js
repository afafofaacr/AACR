/**
 * Created by lauren.lezberg on 3/8/2019.
 */
({
    /**
     * @purpose Checks which process buttons should appear based on step order
     * @param cmp
     * @param event
     * @param helper
     */
    checkButtonVisibility : function(cmp, event, helper){
        console.log('JP_NavButtons checkButtonVisibility...');
        var currentStepId = cmp.get("v.currentStepId");
        var allSteps = cmp.get("v.joinSteps");
        allSteps.forEach(function(step, idx){
            if(step.stepId == currentStepId){
                if(idx == 0){
                    cmp.set("v.showPrevious", false);
                    cmp.set("v.showButtons", true);
                } else if(idx == allSteps.length-1){
                    cmp.set("v.showButtons", false);
                } else {
                    cmp.set("v.showPrevious", true);
                    cmp.set("v.showButtons", true);
                }

            }
        });
    },

    /**
     * @purpose Fires stepChange event to move forward in join process if selected step is the next step in the process
     * @param cmp
     * @param event
     * @param helper
     */
    goNext : function(cmp, event, helper){
        console.log('JP_NavButtons goNext...');

        var stopIdx = 0;
        var currentStepId = cmp.get("v.currentStepId");
        var allSteps = cmp.get("v.joinSteps");
        allSteps.forEach(function(step, idx){
            if(step.stepId == currentStepId){
                stopIdx = idx + 1;
            }
        });

        var navEvt = $A.get("e.c:JP_StepChangeEvt");
        navEvt.setParams({"stepId" : allSteps[stopIdx].stepId});
        navEvt.setParams({"cmpName" : allSteps[stopIdx].componentName});
        navEvt.fire();
    },

    /**
     * @purpose Fires stepChange event to move backward in join process
     * @param cmp
     * @param event
     * @param helper
     */
    goPrevious : function(cmp, event, helper){
        console.log('JP_NavButtons goPrevious...');

        var stopIdx = 0;
        var currentStepId = cmp.get("v.currentStepId");
        var allSteps = cmp.get("v.joinSteps");
        allSteps.forEach(function(step, idx){
            if(step.stepId == currentStepId){
                stopIdx = idx-1;
            }
        });

        var navEvt = $A.get("e.c:JP_StepChangeEvt");
        navEvt.setParams({"stepId" : allSteps[stopIdx].stepId});
        navEvt.setParams({"cmpName" : allSteps[stopIdx].componentName});
        navEvt.fire();
    },

    /**
     * @purpose Cancels current join process and redirects user to cancelURL or back in window history if none is present
     * @param cmp
     * @param event
     * @param helper
     */
    cancelJoin : function(cmp, event, helper){
        console.log('JP_NavButtons cancelJoin...');

        var action = cmp.get("c.getCancelURL");
        action.setParams({
            "stepId": cmp.get("v.currentStepId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cancelURL = response.getReturnValue();
                if(cancelURL!=null){
                    window.location.href = cancelURL;
                } else {
                    window.history.back();
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);

    },


})