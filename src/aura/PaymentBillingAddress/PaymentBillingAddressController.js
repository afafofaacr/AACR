/**
 * Created by lauren.lezberg on 12/14/2020.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('PaymentBillingAddress init...');

        var action = cmp.get("c.getBillingAddressInfo");
        action.setParams({
            "contactId": cmp.get("v.contactId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('billing address data: ' + JSON.stringify(data));

                var custs = [];
                for (var key in data.countryList) {
                    custs.push({label: data.countryList[key], value: key});
                }
                cmp.set("v.countryList", custs);

                if (data.billingAddress != null) {
                    cmp.set("v.billingAddress", data.billingAddress);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Could not get billing address: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not remove item from cart - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get billing address: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    editAddress: function (cmp, event, helper) {
        console.log('PaymentBillingAddress editAddress...');
        var addressId = event.getSource().get("v.value");

        cmp.find('newModal').set("v.addressId", addressId);
        cmp.find("newModal").set("v.isOpen", true);

    },

    openModal: function (cmp) {
        console.log('PaymentBillingAddress openModal...');

        cmp.find('newModal').set("v.isOpen", true);
        var types = ['Billing'];
        cmp.find('newModal').set("v.types", types);
        cmp.find('newModal').set("v.selectedType", 'Billing');
        cmp.find('newModal').find('type').set("v.value", 'Billing');
    },


    closeModal: function (cmp, event, helper) {
        console.log('PaymentBillingAddress closeModal...');

        cmp.find('newModal').set("v.isOpen", false);
        cmp.find('newModal').set("v.addressId", null);

    },

});