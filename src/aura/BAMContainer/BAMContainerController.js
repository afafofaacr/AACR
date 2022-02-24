/**
 * Created by lauren.lezberg on 8/8/2019.
 */
({

    /**
     * @purpose Initialize
     * @param cmp
     * @param event
     * @param helper
     */
    doInit : function(cmp, event, helper){
        console.log('BAMContainer init...');
        cmp.set("v.joinId", helper.getJoinId(cmp));
    },

    /**
     * @purpose Re-initialize the component
     * @param component
     * @param event
     * @param helper
     */
    reInit : function(component, event, helper) {
        console.log('BAMContainer reInit...');
        $A.get('e.force:refreshView').fire();
    },

    /**
     * @purpose Handle navigation event by dynamically constructing component step
     * @param cmp
     * @returns {*}
     */
    handleNavigate : function(cmp, event, helper){
        console.log('BAMContainer handleNavigate...');

        var currentStepId = cmp.get("v.currentStepId");

        //Get data from event
        var stepId = event.getParam("stepId");
        var componentName = event.getParam("cmpName");


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
    }
})