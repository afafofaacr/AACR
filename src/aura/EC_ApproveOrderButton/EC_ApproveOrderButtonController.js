/**
 * Created by afaf.awad on 3/1/2021.
 */

({
    doInit : function(cmp,event,helper){
        console.log('int button order id = ' + cmp.get('v.recordId'));
        $A.get('e.force:refreshView').fire();
    },


    goToApproveOrder: function (cmp, event, helper) {
        cmp.set("v.processing", true);
        var action = cmp.get("c.getOrderForApproval");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var jpId = response.getReturnValue();
                console.log('jpId: ' + jpId);

                var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__BAMContainer',
                    },
                    state: {
                        "c__id": jpId,
                        "c__orderId" : cmp.get("v.recordId")
                    }
                };

                cmp.set("v.processing", false);
                // cmp.set("v.pageReference", pageReference);
                var navService = cmp.find("navService");
                navService.navigate(pageReference);

            } else if (state === "INCOMPLETE") {
                cmp.set("v.processing", false);

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                cmp.set("v.processing", false);
            }
        });
        $A.enqueueAction(action);
    }
});