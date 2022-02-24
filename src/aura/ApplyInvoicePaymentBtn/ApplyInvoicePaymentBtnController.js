/**
 * Created by afaf.awad on 1/13/2021.
 */

({
    doInit : function(cmp,event,helper){
        var action = cmp.get("c.getApplyPaymentJoinId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__ApplyInvoicePayment'
                    },
                    state: {
                        'c__id': data,
                        'c__invoice' : cmp.get("v.recordId")
                    }
                };

                cmp.set("v.pageReference", pageReference);
                var navService = cmp.find("navService");
                navService.navigate(pageReference);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    }

});