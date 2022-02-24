/**
 * Created by lauren.lezberg on 7/7/2021.
 */

({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getInvoice");
        action.setParams({
            "invoiceId" : cmp.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var inv = response.getReturnValue();

                if(inv.OrderApi__Balance_Due__c == 0.0){
                    cmp.set("v.paid", true);
                } else {
                    cmp.set("v.invoiceRecord", inv);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get invoice: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set('v.isLoading', false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get invoice - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get invoice: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});