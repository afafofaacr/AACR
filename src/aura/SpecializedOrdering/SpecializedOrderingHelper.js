/**
 * Created by lauren.lezberg on 2/2/2021.
 */

({
    goToPayNow : function(cmp){
        var itemIds = [];
        var selectedItems = cmp.get("v.selectedItems");

        selectedItems.forEach(function(item){
            console.log('item: ' + JSON.stringify(item));
            itemIds.push(item.Id);
        });

        console.log('itemIds: ' + itemIds);
        console.log('account: ' + cmp.find('accountLookup').get("v.selectedId"));

        var action = cmp.get("c.buildAccountSalesOrder");
        action.setParams({
            "accountId" : cmp.find('accountLookup').get("v.selectedId"),
            "jsonItems" : JSON.stringify(itemIds)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.salesOrderId", data);
                cmp.set("v.showPayment", true);
                cmp.set("v.currentSteps", 'payment');
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

    validateForm : function(cmp, event) {
        console.log('validateForm...');
        var isValid = true;

        if (cmp.get("v.accountId") == null) {
            isValid = false;
            cmp.find('accountLookup').set("v.hasError", true);
        } else {
            cmp.find('accountLookup').set("v.hasError", false);
        }

        if(cmp.find('fieldName').get("v.value")!=null) {
            console.log('recordLookupVal: ' + cmp.find('recordLookup').get("v.selectedId"));
            if (cmp.find('recordLookup').get("v.selectedId") == null || cmp.find('recordLookup').get("v.selectedId") == undefined || cmp.find('recordLookup').get("v.v.selectedId") == '') {
                isValid = false;
                cmp.find('recordLookup').set("v.hasError", true);
            } else {
                cmp.find('recordLookup').set("v.hasError", false);
            }
        }

        if (cmp.get("v.value") == 'invoice') {
            if(cmp.find('email').get("v.value")==null || cmp.find('email').get("v.value")==undefined || cmp.find('email').get("v.value")=='' ){
                isValid = false;
                cmp.find('email').showHelpMessageIfInvalid();
            }

            if (cmp.find('dueDate').get("v.value") == null || cmp.find('dueDate').get("v.value") == undefined || cmp.find('dueDate').get("v.value") == '') {
                isValid = false;
                cmp.find('dueDate').showHelpMessageIfInvalid();
            }

        }




        console.log('returning: ' + isValid);
        return isValid;

    },

    createInvoice : function(cmp, customerId){
        console.log('sendInvoice...');
        var itemIds = [];
        var selectedItems = cmp.get("v.selectedItems");

        selectedItems.forEach(function (item) {
            itemIds.push(item.Id);
        });

        var action = cmp.get("c.sendAccountInvoice");
        action.setParams({
            "customerId" : customerId,
            "jsonItems": JSON.stringify(itemIds),
            "dueDate": cmp.find('dueDate').get("v.value"),
            "fieldName": cmp.find('fieldName') != null ? cmp.find('fieldName').get("v.value") : null,
            "fieldValue": cmp.find('recordLookup') != null ? cmp.find('recordLookup').get("v.selectedId") : null
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data != null) {
                    var invoices = cmp.get("v.invoices");
                    invoices.push(data);
                    cmp.set("v.invoices", invoices);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "Invoice has been sent successfully."
                    });
                    toastEvent.fire();

                    this.clearForm(cmp);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": "Invoice could not be sent."
                    });
                    toastEvent.fire();
                }
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
    },

    handleAccountUpdate : function(cmp){
        return new Promise(function(resolve, reject){
            var action = cmp.get("c.upsertStripeCustomer");
            action.setParams({
                "accountId" : cmp.find('accountLookup').get("v.selectedId"),
                "email" : cmp.find('email').get('v.value'),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    // console.log('data: ' + data);
                    resolve(data);
                }
                else {
                    reject();
                }

            });
            $A.enqueueAction(action);
        });
    },

    clearForm : function(cmp){
        cmp.find('accountLookup').clearAccount();
        cmp.find('dueDate').set("v.value", null);
        cmp.set("v.selectedItems", []);
        cmp.set("v.total", 0.00);
        cmp.set("v.showPayment", false);
        cmp.set("v.salesOrderId", null);
        cmp.set("v.processing", false);
    }
});