/**
 * Created by lauren.lezberg on 9/18/2020.
 */

({
    handleNavigate : function(cmp, event, helper){
        console.log("Handling navigate event from JP_Container");

        var currentStepId = cmp.get("v.currentStepId");
        console.log('currentStepId', currentStepId);

        //Get data from event
        var stepId = event.getParam("stepId");
        console.log('Event: stepId ' + stepId);
        var componentName = event.getParam("cmpName");
        console.log('Event: componentName: ' + componentName);

        // Dynamically create component for specified stepId
        if(componentName!=null && (cmp.get("v.isInitialStep") || currentStepId!=stepId)) {
            if(cmp.get("v.isInitialStep")){
                cmp.set("v.isInitialStep", false);
            }

            cmp.set("v.stepCmp", []);

            $A.createComponent(
                "c:" + componentName,
                {
                    "stepId": stepId,
                    "aura:id": 'stepCmp'
                },
                function (stepCmp, status, errorMessage) {
                    //Add the new button to the body array
                    if (status === "SUCCESS") {
                        var cmpInput = cmp.get("v.stepCmp");
                        cmpInput.push(stepCmp);
                        cmp.set("v.stepCmp", cmpInput);
                    } else if (status === "INCOMPLETE") {
                        console.log("Could not create component: No response from server or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("Could not create component: Error - " + errorMessage);
                    }
                });
            cmp.set("v.currentStepId", stepId);
        } else {
            cmp.set("v.currentStepId", stepId);
        }
    },

    // handleCodeSuccess : function(cmp, event, helper){
    //     console.log('handleCodeSuccess Aura');
    //     console.log('Source Code ID: ' + event.getParam("sourceCodeId"));
    //     console.log('Code validation result: ' + event.getParam("result"));
    //     console.log('Membership ID: ' + event.getParam("membershipId"));
    //     console.log('Used Mode: ' + event.getParam("usedMode"));

    //     // This event will only fire from the validateOfferCode component
    //     // when the code is validated and result is true
    // }
    handleCodeSuccess : function(cmp, event, helper){
        console.log('handleCodeSuccess Aura');
        // cmp.set("v.vResult", event.detail);
        // console.log('vResult: ' + JSON.parse(JSON.stringify(cmp.get("v.vResult"))));
        cmp.set("v.vResult.sourceCodeId", event.getParam("sourceCodeId"));
        cmp.set("v.vResult.validationResult", event.getParam("result"));
        cmp.set("v.vResult.offerMembershipId", event.getParam("membershipId"));
        cmp.set("v.vResult.usedMode", event.getParam("usedMode"));
        console.log('vResult.sourceCodeId: ' + cmp.get("v.vResult.sourceCodeId"));
        console.log('vResult.validationResult: ' + cmp.get("v.vResult.validationResult"));
        console.log('vResult.offerMembershipId: ' + cmp.get("v.vResult.offerMembershipId"));
        console.log('vResult.usedMode: ' + cmp.get("v.vResult.usedMode"));

    },

    handleCodeError : function(cmp, event, helper){
        console.log('handleCodeError Aura');
        cmp.set("v.vResult.sourceCodeId", event.getParam("sourceCodeId"));
        cmp.set("v.vResult.validationResult", event.getParam("result"));
        cmp.set("v.vResult.offerMembershipId", event.getParam("membershipId"));
        cmp.set("v.vResult.usedMode", event.getParam("usedMode"));
        console.log('vResult.sourceCodeId: ' + cmp.get("v.vResult.sourceCodeId"));
        console.log('vResult.validationResult: ' + cmp.get("v.vResult.validationResult"));
        console.log('vResult.offerMembershipId: ' + cmp.get("v.vResult.offerMembershipId"));
        console.log('vResult.usedMode: ' + cmp.get("v.vResult.usedMode"));
    }
});