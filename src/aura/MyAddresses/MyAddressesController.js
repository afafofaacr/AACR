/**
 * Created by lauren.lezberg on 9/8/2020.
 */

({

    doInit: function (cmp, event, helper) {
        console.log('MyAddresses init...');

        helper.getValidAddresses(cmp, event);
    },

    addAddress : function(cmp, event, helper){
        console.log('MyAddresses addAddress...');

        cmp.set("v.processing", true);
        cmp.find('addressForm').submitForm();
        helper.getValidAddresses(cmp, event);
    },

    editAddress: function (cmp, event, helper) {
        console.log('MyAddresses editAddress...');
        var addressId = event.getSource().get("v.value");

        cmp.find('newModal').set("v.addressId", addressId);
        cmp.find("newModal").set("v.isOpen", true);

    },

    handleAddressChange: function (cmp, event, helper) {
        console.log('MyAddresses handleAddressChange...');

        var accountId = event.getParam('value');

        if(accountId==null){
            cmp.set("v.errorMsg", 'You are no longer affiliated. Please delete or update your business address. If you wish to remove it and it is your primary address, you will need to select a new primary address before doing so.');
        } else {

            var action = cmp.get("c.updateBusinessAddress");
            action.setParams({
                "contactId": cmp.get("v.contactId"),
                "accountId": accountId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    if (storeResponse) {
                        cmp.set('v.errorMsg', null);
                        helper.getValidAddresses(cmp, event);
                    }
                } else if (state == "INCOMPLETE") {
                    console.log('Incomplete callout');
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Could not get addresses - Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Could not get addresses: Unknown error");
                    }
                }

            });

            $A.enqueueAction(action);
        }
    },

    removeAddress: function (cmp, event, helper) {
        console.log('MyAddresses removeAddress...');
        var addressId = event.getSource().get("v.value");

        var action = cmp.get("c.deleteKnownAddress");
        action.setParams({
            "kaID": addressId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.getValidAddresses(cmp, event);
            } else if (state == "INCOMPLETE") {
                console.log('Incomplete callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get addresses - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get addresses: Unknown error");
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    },

    changeDefault: function (cmp, event, helper) {
        console.log('MyAddresses changeDefault...');

        var defaultId = event.getSource().get("v.value");

        var action = cmp.get("c.updateDefault");
        action.setParams({
            "defaultId": defaultId,
            "contactId": cmp.get("v.contactId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.getValidAddresses(cmp, event);
            } else if (state == "INCOMPLETE") {
                console.log('Incomplete callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get addresses - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get addresses: Unknown error");
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    },

    openNewModal: function (cmp, event, helper) {
        console.log('MyAddresses openNewModal...');

        cmp.find('newModal').set("v.selectedType", null);
        cmp.find('newModal').set("v.address", {});
        cmp.find("newModal").set("v.isOpen", true);
    }
});