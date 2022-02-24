/**
 * Created by afaf.awad on 1/13/2021.
 */

({
    doInit : function(cmp,event,helper){
        cmp.set('v.joinId', helper.getJoinId());
        var action = cmp.get("c.getSalesOrder");
        action.setParams({
            "invoiceId" : helper.getInvoiceId()
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('invoice = ' + JSON.stringify(data));
                console.log('joinId = ' + cmp.get('v.joinId'));
                cmp.set('v.invoiceList', data);

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
    },

    cancelPayment : function(cmp,event,helper){
            window.history.back();
    }
});