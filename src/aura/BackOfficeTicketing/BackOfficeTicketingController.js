/**
 * Created by lauren.lezberg on 10/7/2019.
 */
({
    doInit : function(cmp, event, helper){
        cmp.set("v.salesOrderId", helper.getSalesOrderId(cmp));
        cmp.set("v.isRenewal", helper.getIsRenew(cmp));

        var action = cmp.get("c.getBackOfficeData");
        action.setParams({
            "salesOrderId" : helper.getSalesOrderId(cmp),
            "isRenew" : helper.getIsRenew(cmp)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data.lines);
            }
            else if (state === "INCOMPLETE") {
                cmp.set("v.processing", false);
                cmp.set("v.errorMsg", 'Could not retrieve data: Incomplete Callout.');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        cmp.set("v.errorMsg", 'Could not retrieve data- Error message: ' +
                        errors[0].message);
                    }
                } else {
                    cmp.set("v.errorMsg", 'Could not retrieve data: Unknown Error');
                }
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Add selected item to sales order with selected term, reset item list to include new item and clear item lookup
     * @param cmp
     * @param event
     * @param helper
     */
    addItemToSalesOrder : function(cmp, event, helper){
        cmp.set("v.processing", true);
        cmp.set("v.errorMsg", null);

        var action = cmp.get("c.addSelectedItem");
        action.setParams({
            "itemId" : cmp.get("v.selectedId"),
            "subPlanId" : null,
            "futureEndDate" : false,
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data);
                cmp.set("v.selectedId", null);
                cmp.find('itemLookup').clearAccount();
                cmp.set("v.processing", false);
            }
            else if (state === "INCOMPLETE") {
                cmp.set("v.errorMsg", 'Could not add item. Incomplete Callout.');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        cmp.set("v.errorMsg", "Could not retrieve data - Error message: " +
                        errors[0].message);
                    }
                } else {
                    cmp.set("v.errorMsg", 'Could not add item: Unknown error');
                }
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Removes selected item from list by deleting sales order line, updating list of items and clearing item lookup
     * @param cmp
     * @param event
     * @param helper
     */
    removeItemFromSalesOrder : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var selectedItem = event.getSource().get("v.value");
        var action = cmp.get("c.removeItem");
        action.setParams({
            "itemId" : selectedItem,
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data);
                cmp.set("v.selectedId", null);
                cmp.find('itemLookup').clearAccount();
                cmp.set("v.processing", false);
            }
            else if (state === "INCOMPLETE") {
                cmp.set("v.errorMsg", 'Could not remove item. Incomplete Callout.');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        cmp.set("v.errorMsg", "Could not remove item - Error message: " +
                            errors[0].message);
                    }
                } else {
                    cmp.set("v.errorMsg", 'Could not remove item: Unknown error');
                }
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Performs validation check to make sure there is an item added and user is redirected to next step in process, otherwise, user receives and error message and stays on the same page
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave : function(cmp, event, helper){
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var lines = cmp.get("v.salesOrderLines");
        if(lines.length>0) {
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        } else {
            cmp.set("v.errorMsg", 'You must add an item before continuing.');
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }

    }

})