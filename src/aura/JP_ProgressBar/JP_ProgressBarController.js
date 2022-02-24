/**
 * Created by lauren.lezberg on 1/10/2019.
 */
({
    doInit: function(cmp, event, helper){
        console.log('JP_ProgressBar init...');
        var salesOrderId = helper.getSalesOrderId(cmp);
        var joinId = helper.getJoinId(cmp);

        var action = cmp.get("c.getProgressBarData");
        action.setParams({
            "joinId": joinId,
            "salesOrderId" : salesOrderId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.joinSteps", data.steps);
                cmp.set("v.currentStepId", data.lastStepId);

                if(data.membershipType!=undefined) {
                    if (data.isRenewal) {
                        cmp.set("v.pathLabel", 'Renew > ' + data.membershipType);
                    } else {
                        cmp.set("v.pathLabel", 'Apply > ' + data.membershipType);
                    }
                }

                var cmpName = '';
                data.steps.forEach(function(js){
                    if(js.stepId == data.lastStepId){
                        cmpName = js.componentName;
                    }
                });


                var stepChangeEvt = $A.get("e.c:JP_NavigateEvt");
                stepChangeEvt.setParams({"stepId" : data.lastStepId});
                stepChangeEvt.setParams({"cmpName" : cmpName});
                stepChangeEvt.fire();


            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
            }
        });
        $A.enqueueAction(action);

    },


    /**
     * @purpose Handles progress bar being clicked and determines if step is before or one step after the current step before firing StepChange event
     * @param cmp
     * @param event
     * @param helper
     */
    onStepChange : function(cmp, event, helper){
        console.log('JP_ProgressBar onStepChange...');

        //get step clicked
        var oldStep = cmp.get("v.currentStepId");
        var step = event.getSource().get('v.value');
        
        //find component name
        var cmpName = '';
        var oldCmpName = '';
        var oldStepOrder = 0.0;
        var newStepOrder = 0.0;
        var steps = cmp.get("v.joinSteps");

        //find old step and new step info
        steps.forEach(function(js){
            if(js.stepId == oldStep){
                oldStepOrder = js.stepOrder;
                oldCmpName = js.componentName;
            }
            if(js.stepId == step){
                cmpName = js.componentName;
                newStepOrder = js.stepOrder;
            }
        });

        cmp.set("v.currentStepId", null);
        //if step clicked is next step or previous step continue
        if(newStepOrder < oldStepOrder || newStepOrder == oldStepOrder + 1) {
            //fire step change event
            var stepChangeEvt = $A.get("e.c:JP_StepChangeEvt");
            stepChangeEvt.setParams({"stepId": step});
            stepChangeEvt.setParams({"cmpName": cmpName});
            stepChangeEvt.fire();


        } else { //if step clicked is more than one step ahead, go back to old step
            cmp.set("v.currentStepId", oldStep);

        }
    },


})