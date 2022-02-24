/**
 * Created by lauren.lezberg on 2/2/2021.
 */

({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getAvailableObjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                cmp.set("v.availableObjects", data);
                var objectOptions = [];
                data.forEach(function(obj){
                    objectOptions.push({label:obj.MasterLabel, value:obj.Field_API_Name__c});
                });
                cmp.set("v.objectOptions", objectOptions);
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
    },

    handleChange : function(cmp, event, helper){
        var selectedOptionValue = event.getParam("value");
        console.log('selectedOption: ' + selectedOptionValue);
        var availableObjects = cmp.get("v.availableObjects");
        var objAPIName;
        availableObjects.forEach(function(obj){
           if(obj.Field_API_Name__c = selectedOptionValue){
               objAPIName = obj.Object_API_Name__c;
           }
        });

        cmp.set("v.objAPIName", objAPIName);

        if(selectedOptionValue!=null && selectedOptionValue!=undefined && selectedOptionValue!=''){
            cmp.find('recordLookup').set("v.isRequired", true);
        } else {
            cmp.find('recordLookup').set("v.isRequired", false);
        }

    },

    sendInvoice : function(cmp, event, helper){
        if(helper.validateForm(cmp, event)) {
            cmp.set("v.processing", true);

            helper.handleAccountUpdate(cmp)
                .then($A.getCallback(function (customerId) {
                    console.log('resolve: ' + customerId);
                    helper.createInvoice(cmp, customerId);
                }))
                .catch($A.getCallback(function () {
                    cmp.set('v.isLoading', false);
                }));
        }
    },

    payNow : function(cmp, event, helper){
        console.log('payNow...');

        if(helper.validateForm(cmp, event)) {
            cmp.set("v.processing", true);
            var itemIds = [];
            var selectedItems = cmp.get("v.selectedItems");

            selectedItems.forEach(function (item) {
                console.log('item: ' + JSON.stringify(item));
                itemIds.push(item.Id);
            });

            console.log('itemIds: ' + itemIds);
            console.log('account: ' + cmp.find('accountLookup').get("v.selectedId"));

            var action = cmp.get("c.buildAccountSalesOrder");
            action.setParams({
                "accountId": cmp.find('accountLookup').get("v.selectedId"),
                "jsonItems": JSON.stringify(itemIds),
                "fieldName": cmp.find('fieldName') != null ? cmp.find('fieldName').get("v.value") : null,
                "fieldValue": cmp.find('recordLookup') != null ? cmp.find('recordLookup').get("v.selectedId") : null
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    cmp.set("v.salesOrderId", data);
                    cmp.set("v.showPayment", true);
                    cmp.set("v.processing", false);
                } else if (state === "INCOMPLETE") {
                    console.log('Could not retrieve data: Incomplete Callout');
                    cmp.set("v.processing", false);
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    cmp.set("v.processing", false);
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
    },

    handleTypeToggle : function(cmp,event, helper){
        if(cmp.get("v.value") == 'invoice'){
            cmp.set("v.showPayment", false);
        }
    },

    removeItemFromSalesOrder : function(cmp, event, helper){
        var selectedId = event.getSource().get("v.value");
        var selectList = cmp.get("v.selectedItems");
        var total = cmp.get("v.total");

        selectList.forEach(function(s, idx){
            if(selectedId == s.Id){
                selectList.splice(idx, 1);
                total -= s.OrderApi__Price__c;
            }

        });

        cmp.set("v.total", total);
        cmp.set("v.selectedItems", selectList);

        if(cmp.get("v.salesOrderId")!=null) {
            var action = cmp.get("c.removeSOLine");
            action.setParams({
                "itemId": selectedId,
                "salesOrderId": cmp.get("v.salesOrderId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                } else if (state === "INCOMPLETE") {
                    console.log('Could not retrieve data: Incomplete Callout');
                } else if (state === "ERROR") {
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

    },

    addItemToSalesOrder : function(cmp, event, helper){
        var selected = cmp.find('itemLookup').get("v.selection");
        // console.log('selected: ' + JSON.stringify(selected));
        if(selected.Id!=null) {

            var selectList = cmp.get("v.selectedItems");
            selectList.push(selected);

            var total = cmp.get("v.total");
            total += selected.OrderApi__Price__c;

            cmp.set("v.total", total);

            cmp.set("v.selectedItems", selectList);

            if (cmp.get("v.salesOrderId") != null) {
                var action = cmp.get("c.createSOLine");
                action.setParams({
                    "itemId": selected.Id,
                    "salesOrderId": cmp.get("v.salesOrderId")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var data = response.getReturnValue();
                    } else if (state === "INCOMPLETE") {
                        console.log('Could not retrieve data: Incomplete Callout');
                    } else if (state === "ERROR") {
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

            var itemLookup = cmp.find('itemLookup');
            [].concat(itemLookup)[0].clearAccount();
        }

    }
});