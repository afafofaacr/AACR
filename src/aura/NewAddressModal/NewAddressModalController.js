/**
 * Created by lauren.lezberg on 9/9/2020.
 */

({

    addressIdChange: function (cmp, event, helper) {
        console.log('NewAddressModal addressIdChange...');
        var oldAddress = event.getParam("oldValue");
        var addressId = cmp.get("v.addressId");
        if (addressId!=oldAddress && addressId != null && addressId != undefined) {

            var action = cmp.get("c.getAddress");
            action.setParams({
                "addressId": addressId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    cmp.find('addressForm').set("v.recordId", addressId);

                    var types = cmp.get("v.types");
                    if(!types.includes(resp.Type__c)){
                        types.push(resp.Type__c);
                    }
                    cmp.set("v.types", types);
                    cmp.set("v.selectedType", resp.Type__c);

                    helper.getAddressDetails(cmp, resp.Manual_Entry__c, resp, addressId);

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
        }
    },

    toggleManualEntry: function (cmp, event, helper) {
        console.log('NewAddressModal toggleManualEntry...');

        if (cmp.get("v.manual")) {
            cmp.set("v.manual", false);
        } else {
            cmp.set("v.manual", true);
            //if address already entered via search bar - set country/state values
            if(cmp.get("v.address")!=null){
                var address = cmp.get("v.address");
                var countryList = cmp.get("v.countryList");

                countryList.forEach(function(c){
                    if(c.label == address.country){
                        address.countryCode = c.value;
                    }
                });

                if (address.state != null) {
                    var statePromise = helper.getNewStatesList(cmp, address.countryCode)
                    statePromise.then(
                        $A.getCallback(function (result) {
                            // We have the account - set the attribute
                            var stateList = cmp.get('v.stateList');
                            stateList.forEach(function (s) {
                                if (s.label == address.state) {
                                    address.stateCode = s.value;
                                }
                            });

                            cmp.set("v.address", address);
                        }),
                        $A.getCallback(function (error) {
                            alert('An error has occurred : ' + error.message);
                        })
                    );
                } else {
                    cmp.set("v.address", address);

                }
            }
        }
    },

    closeModal: function (cmp, event, helper) {
        console.log('NewAddressModal closeModal...');

        cmp.set("v.addressId", null);
        cmp.set("v.isOpen", false);
        cmp.set("v.manual", false);
    },

    checkType: function (cmp, event, helper) {
        console.log('NewAddressModal checkType...');

        var type =  event.getSource().get("v.value");
        cmp.find('type').set("v.value", type);

        if (type == 'Other') {
            cmp.set("v.showDetails", true);
        } else {
            cmp.set("v.showDetails", false);
        }
    },

    handleSubmit: function (cmp, event, helper) {
        console.log('NewAddressModal handleSubmit...');
        event.preventDefault();


        if (helper.validateForm(cmp)) {

            var address = cmp.get("v.address");


            var street = address.street1;
            if (address.street2 != null) {
                street += ', ' + address.street2;
            }
            if (address.street3 != null) {
                street += ', ' + address.street3;
            }
            cmp.find('kastreet').set("v.value", street);
            cmp.find('kacity').set('v.value', address.city);
            cmp.find('kazip').set("v.value", address.zip);

            if (cmp.get("v.manual")) {
                var countryList = cmp.get('v.countryList');
                countryList.forEach(function (c) {
                    if (c.value == address.countryCode) {
                        cmp.find('kacountry').set("v.value", c.label);
                    }
                });

                if (address.stateCode != null) {
                    var stateList = cmp.get('v.stateList');
                    stateList.forEach(function (s) {
                        if (s.value == address.stateCode) {
                            cmp.find('kastate').set("v.value", s.label);
                        }
                    });
                }


            } else {
                cmp.find('kacountry').set("v.value", address.country);
                cmp.find('kastate').set("v.value", address.state);

            }

            cmp.find('addressForm').submit();
        } else {
            console.log('not valid');
        }
    },

    handleSuccess: function (cmp, event, helper) {
        console.log('NewAddressModal handleSuccess...');

        var cmpEvent = cmp.getEvent("newAddress");
        cmpEvent.setParams({
            "contactId": cmp.get("v.contactId")
        });
        cmpEvent.fire();
        cmp.set('v.isOpen', false);
        cmp.set("v.addressId", null);
    },

    handleError: function (cmp, event, helper) {
        console.log('NewAddressModal handleError...');

        console.log('ERROR SAVING RECORD.');
    },

    onCountryChange: function (cmp, event, helper) {
        console.log('NewAddressModal onCountryChange...');

        var changeValue = event.getSource().get("v.value");
        // console.log("value: " + changeValue);

        var address = cmp.get("v.address");
        if(typeof address == 'string') {
            address = {};
        }
        address.countryCode = changeValue;
        cmp.set("v.address", address);


        if (changeValue == null || changeValue == '') {
            $A.util.removeClass(cmp.find("state"), "slds-has-error");
            $A.util.addClass(cmp.find("state"), "hide-error-message");
        }
        helper.getNewStatesList(cmp, changeValue);

    }
});