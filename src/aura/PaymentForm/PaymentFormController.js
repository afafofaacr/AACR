/**
 * Created by lauren.lezberg on 2/5/2020.
 */
({

    doInit : function(cmp, event, helper){
        cmp.set("v.isModify", helper.getIsModify(cmp));
        cmp.set("v.salesOrderId", helper.getSalesOrderId(cmp));
        console.log(helper.getJoinId(cmp));

        var action = cmp.get("c.getPayNowData");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "joinId" : helper.getJoinId(cmp)
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cartData = response.getReturnValue();
                console.log('cartData: ' + JSON.stringify(cartData));
                //set payNow component attributes
                cmp.set("v.store", cartData.store);
                cmp.set("v.environmentKey", cartData.environmentKey);
                cmp.set("v.redirectURL", cartData.redirectURL);
                cmp.set("v.windowLocation", window.location.href);
                cmp.set("v.processing", false);

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve cart item data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve cart item data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve cart item data: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    /**
     * @purpose Cancels current order by deleting the associated sales order and redirecting the user to either the join cancel url or the last url in the history
     * @param cmp
     * @param event
     * @param helper
     */
    cancelOrder : function(cmp, event, helper){
        var action = cmp.get("c.deleteSalesOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var cancelURL = response.getReturnValue();
                if(cancelURL!=null){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": cancelURL
                    });
                    urlEvent.fire();
                } else {
                    window.history.back();
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not cancel order: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not cancel order - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not cancel order: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    processCheckPayment : function(cmp, event, helper){
        var action = cmp.get("c.closeSalesOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.showCheckForm", true);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process payment: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process payment: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    processPayment : function (cmp, event, helper) {

        var action = cmp.get("c.payNow");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //Calling Fonteva's PayNow process payment method
                // cmp.find("payNowCmp").validateTokenPayment();

                cmp.find("payNowCmp").processTokenPayment();

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process payment: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process payment: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },

    processEmptyPayment : function (cmp, event, helper) {
        cmp.set("v.processing", true);

        var action = cmp.get("c.processZeroDollarPayment");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = cmp.get("v.redirectURL");
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve data: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})