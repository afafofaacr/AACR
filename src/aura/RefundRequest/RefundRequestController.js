/**
 * Created by lauren.lezberg on 12/2/2020.
 */

({

    handleTypeToggle : function(cmp,event, helper){
        if(cmp.get("v.refundVal") == 'partial'){
            var action = cmp.get("c.getReceiptLines");
            action.setParams({
                "receiptId": cmp.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var receiptLines = response.getReturnValue();
                    cmp.set("v.receiptLines", receiptLines);

                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout');
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
                }

            });
            $A.enqueueAction(action);
        }
    },

    startRefundProcess : function(cmp, event, helper){
        cmp.set("v.processing", true);

        if(cmp.get("v.refundVal")=='full') {
            helper.startRefund(cmp);
        } else {
            helper.startPartialRefund(cmp);
        }
    },

    cancel : function(cmp, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }

});