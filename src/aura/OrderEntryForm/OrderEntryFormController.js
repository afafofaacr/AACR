/**
 * Created by lauren.lezberg on 10/24/2019.
 */
({

    clearSelection : function(cmp, event, helper){
        console.log('OrderEntryForm clearSelection...');

        var itemLookup = cmp.find('itemLookup');
        [].concat(itemLookup)[0].clearAccount();
    },


    /**
     * @purpose Add selected item to sales order with selected term, reset item list to include new item and clear item lookup
     * @param cmp
     * @param event
     * @param helper
     */
    addItemToSalesOrder : function(cmp, event, helper){
        console.log('OrderEntryForm addItemToSalesOrder...');
        cmp.set("v.processing", true);
        cmp.set("v.errorMsg", null);


        var subPlanId = cmp.get("v.subPlanId");
        var futureEndDate = false;
        var selectedTerm = cmp.get("v.selectedTerm");
        if(selectedTerm!=null && selectedTerm!='' && selectedTerm!=undefined){
            if(cmp.get("v.selectedTerm") > new Date().getFullYear().toString()){
                futureEndDate = true;
            }
        }

        var action = cmp.get("c.addSelectedItem");
        action.setParams({
            "itemId" : cmp.get("v.selectedId"),
            "subPlanId" : subPlanId,
            "futureEndDate" : futureEndDate,
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data);
                data.forEach(function(line){
                    if(line.OrderApi__Item_Class__r.Name=='Individual Memberships') {
                        if (line.OrderApi__Item__r.Name.includes('Emeritus') || line.OrderApi__Item__r.Name.includes('Honorary')) {
                            cmp.set("v.showLifetimeWarning", true);
                        } else {
                            cmp.set("v.subPlanId", line.OrderApi__Subscription_Plan__c);
                        }
                    }
                });

                cmp.set("v.selectedId", null);
                cmp.set("v.processing", false);
                var itemLookup = cmp.find('itemLookup');
                [].concat(itemLookup)[0].clearAccount();
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
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
        console.log('OrderEntryForm removeItemToSalesOrder...');

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
                //clear sub plan if there's no membership
                var hasMembership = false;
                data.forEach(function(line){
                    if(line.OrderApi__Item_Class__r.Name=='Individual Memberships'){
                        hasMembership = true;
                    }
                });
                if(!hasMembership){
                    cmp.set("v.subPlanId", null);
                }
                cmp.set("v.selectedId", null);
                cmp.set("v.processing", false);
                var itemLookup = cmp.find('itemLookup');
                [].concat(itemLookup)[0].clearAccount();
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
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
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },
})