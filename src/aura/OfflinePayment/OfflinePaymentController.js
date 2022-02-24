/**
 * Created by lauren.lezberg on 7/7/2021.
 */

({
    doInit : function(cmp, event, helepr){
        var action = cmp.get("c.getPaymentInfo");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var paymentInfo = response.getReturnValue();
                cmp.set("v.salesOrder", paymentInfo.so);
                cmp.set("v.balanceDue", paymentInfo.balanceDue);
                cmp.set("v.amount", paymentInfo.balanceDue);
                cmp.set("v.depositAccount", paymentInfo.defaultDepositAccount);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get sales order: Incomplete Callout');
                cmp.set("v.errorMsg", 'Could not get sales order: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set('v.isLoading', false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get sales order - Error message: " +
                            errors[0].message);
                        cmp.set("v.errorMsg", 'Could not get sales order: ' + errors[0].message);
                    }
                } else {
                    console.log("Could not get sales order: Unknown error");
                    cmp.set("v.errorMsg", 'Could not get sales order: Unknown error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleSubmit : function(cmp, event, helper){
        event.stopPropagation();
        event.preventDefault();

        console.log('handleSubmit....');
        var amount = cmp.get("v.amount");
        console.log('amount: ' + amount);
        var balanceDue = cmp.get("v.balanceDue");
        console.log('balanceDue: ' + balanceDue);
        if(amount>balanceDue){
            console.log('ERROR');
            cmp.set("v.errorMsg", 'Payment amount cannot be more than balance due.');
            return false;
        } else {
            console.log('submitting form....');
            cmp.find('editForm').submit();
        }
    },

    handleSuccess : function(cmp, event, helper){
        console.log('amount: ' + cmp.get("v.amount"));
        var salesOrderId = cmp.get("v.salesOrder.Id");
        var payload = event.getParams().response;
        var recId = payload.id;

        cmp.set("v.isLoading", true);

        var action = cmp.get("c.finishOfflinePayment");
        action.setParams({
            "salesOrderId" : salesOrderId,
            "receiptId": recId,
            "amount" : cmp.get("v.amount")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = '/' + salesOrderId;
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process offline payment: Incomplete Callout');
                cmp.set("v.errorMsg", 'Could not process offline payment: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                cmp.set('v.isLoading', false);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not process offline payment - Error message: " +
                            errors[0].message);
                        cmp.set("v.errorMsg", 'Could not process offline payment: ' + errors[0].message);
                    }
                } else {
                    console.log("Could not process offline payment: Unknown error");
                    cmp.set("v.errorMsg", 'Could not process offline payment: Unknown error');
                }
            }
        });
        $A.enqueueAction(action);

    },

});