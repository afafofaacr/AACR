/**
 * Created by lauren.lezberg on 10/9/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('BackOfficeCheckout init...');
        cmp.set("v.salesOrderId", helper.getSalesOrderId(cmp));
        cmp.set("v.joinId", helper.getJoinId(cmp));
        helper.initialize(cmp, event);

    },

    /**
     * @purpose Open fonteva check processing component
     * @param cmp
     * @param event
     * @param helper
     */
    processCheckPayment : function(cmp, event, helper){
        console.log('BackOfficeCheckout processCheckPayment...');
        var action = cmp.get("c.closeSalesOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.showCheckForm", true);
                cmp.find('salesOrder').set("v.currentTabOpen", 'offline');
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

    /**
     * @purpose Close fonteva check component
     * @param cmp
     * @param event
     * @param helper
     */
    hideCheckForm : function(cmp, event, helper){
        console.log('BackOfficeCheckout hideCheckForm...');
        cmp.set("v.showCheckForm", false);
    },

    /**
     * @purpose Applies discount code to sales order and refreshes sales order lines to reflect new prices
     * @param cmp
     * @param event
     * @param helper
     */
    applyDiscount : function(cmp, event, helper){
        console.log('BackOfficeCheckout applyDiscount...');
        cmp.set("v.applyingDiscount", true);
        var action = cmp.get("c.applyDiscountCode");
        action.setParams({
            "code" : cmp.get("v.discountCode"),
            "salesOrderId" : cmp.get("v.salesOrderId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(response){
                    helper.initialize(cmp, event);
                } else {
                    alert('Error, could not apply discount. Please contact membership at membership@aacr.org.');
                }

                //set sales order to null and back to refresh iframe
                var soID = cmp.get("v.salesOrderId");
                cmp.set("v.salesOrderId", null);
                cmp.set("v.salesOrderId", soID);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not apply discount - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not apply discount: Unknown error");
                }
            }
            cmp.set("v.applyingDiscount", false);
        });
        $A.enqueueAction(action);
    },


    /**
     * @purpose Removes item from sales order
     * @param cmp
     * @param event
     * @param helper
     */
    removeItem : function(cmp, event, helper){
        console.log('BackOfficeCheckout removeItem...');
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

    handleSave : function(cmp, event, helper){
        console.log('BackOfficeCheckout handleSave...');
        // handling redirect
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId" : stepId});
        navEvt.setParams({"cmpName" : cmpName});
        navEvt.fire();

    },


})