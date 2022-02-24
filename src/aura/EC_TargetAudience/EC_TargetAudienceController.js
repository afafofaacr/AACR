/**
 * Created by afaf.awad on 2/24/2021.
 */

({
    doInit: function (cmp, event, helper) {
        cmp.set('v.orderId', helper.getOrderId(cmp));
        var action = cmp.get("c.getTargetCount");
        action.setParams({
            orderId: cmp.get('v.orderId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('count = ' + response.getReturnValue());
                cmp.set('v.count', response.getReturnValue());

            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
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

    refresh: function(cmp,event,helper){
        console.log('refreshing...');
    }

});