/**
 * Created by lauren.lezberg on 2/21/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('JP_CheckoutCart init...');

        cmp.set("v.salesOrderId", helper.getSalesOrderId(cmp));
        cmp.set("v.joinId", helper.getJoinId(cmp));
        cmp.set('v.isInvoice', helper.getIsInvoice(cmp));
        helper.initialize(cmp, event);
    },


    handleCheckoutCodeSuccess : function(cmp, event, helper){
        console.log('JP_CheckoutCart handleCheckoutCodeSuccess...');

        //set sales order to null and back to refresh iframe
        var soID = cmp.get("v.salesOrderId");
        cmp.set("v.salesOrderId", null);
        cmp.set("v.salesOrderId", soID);

        helper.initialize(cmp, event);
    },



    /**
     * Calls apex method to delete sales order line that contains the specified item and then refreshes all sales order lines
     * @param cmp
     * @param event
     * @param helper
     */
    removeItem : function(cmp, event, helper){
        console.log('JP_CheckoutCart removeItem...');

        var solId = event.getSource().get("v.value");
        cmp.set("v.processing", true);
        var action = cmp.get("c.deleteCartItem");
        action.setParams({
            "salesOrderLineId" : solId
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.initialize(cmp, event);
                cmp.set("v.processing", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not remove item from cart: Incomplete Callout');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not remove item from cart - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not remove item from cart: Unknown error");
                }
                cmp.set("v.processing", false); 
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * Response to join process step change event and moves forward or backward in current process
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave : function(cmp, event, helper){
        console.log('JP_CheckoutCart handleSave...');

        // handling redirect
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId" : stepId});
        navEvt.setParams({"cmpName" : cmpName});
        navEvt.fire();

    },

    submitOrder : function(cmp, event, helper){
        console.log('JP_CheckoutCart submitOrder...');

        cmp.set('v.processing', true);
        var action = cmp.get("c.submitApplication");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = '/MemberProfile';
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

    cancelOrder : function(cmp, event, helper){
        console.log('JP_CheckoutCart cancelOrder...');

        cmp.set('v.processing', true);
        var action = cmp.get("c.deleteSalesOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = '/MemberProfile';
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
    }


})