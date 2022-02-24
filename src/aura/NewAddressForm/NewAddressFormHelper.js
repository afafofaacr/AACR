/**
 * Created by lauren.lezberg on 1/12/2021.
 */

({
    validateForm : function(cmp, event, helper){
        console.log('NewAddressForm validateForm...');
        var isValid = true;

        var typeCmp = cmp.find('typeSelect');
        if(typeCmp.get("v.value")==null || typeCmp.get("v.value")==undefined){
            $A.util.addClass(typeCmp, 'slds-has-error');
            isValid = false;
        } else {
            $A.util.removeClass(typeCmp, 'slds-has-error');
        }

        var address = cmp.get("v.address");
        // console.log('address: ' + JSON.stringify(address));

        if(cmp.get("v.manual")) {
            // console.log('address is manual');

            if (address.street1 == null) {
                cmp.find('street1').showHelpMessageIfInvalid();
                isValid = false;
            }

            if (address.city == null) {
                cmp.find('city').showHelpMessageIfInvalid();
                isValid = false;
            }

            if (address.country == null && address.countryCode==null) {
                cmp.find('country').showHelpMessageIfInvalid();
                isValid = false;
            } else if(address.country!=null && (address.countryCode=='US' || address.country == 'CA')) {
                if (address.state == null && address.stateCode == null) {
                    cmp.find('state').showHelpMessageIfInvalid();
                    isValid = false;
                }
            }

            if (address.zip == null) {
                cmp.find('zip').showHelpMessageIfInvalid();
                isValid = false;
            }

            // console.log('isValid: ' + isValid);
        } else {

            if (address.street1 == null || address.zip == null || address.country==null) {
                // console.log(address.street1);
                // console.log(address.zip);
                // console.log(address.country);
                $A.util.addClass(cmp.find("autoAddress"), 'slds-has-error');
                cmp.set("v.errorMsg", 'Address must always have street, country and postal code.');
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find("autoAddress"), 'slds-has-error');
                cmp.set("v.errorMsg", null);
            }
        }

        return isValid;
    },

    getAddressDetails : function(cmp, manual, ka, addressId){
        console.log('NewAddressForm getAddressDetails...');

        if(manual){
            cmp.set("v.manual", true);

            var address = {};
            var countryList = cmp.get('v.countryList');
            countryList.forEach(function(c){
                if(c.label == ka.OrderApi__Country__c){
                    address.countryCode = c.value;

                }
            });

            var statePromise = this.getNewStatesList(cmp, address.countryCode)
            statePromise.then(
                $A.getCallback(function(result){
                    // We have the account - set the attribute

                    if (ka.OrderApi__Province__c != null) {
                        var stateList = cmp.get('v.stateList');
                        stateList.forEach(function (s) {
                            if (s.label == ka.OrderApi__Province__c) {
                                address.stateCode = s.value;
                            }
                        });
                    }

                    var streets = ka.OrderApi__Street__c.split(',');
                    if(streets.length>0){
                        if(streets[0]!=null){
                            address.street1 = streets[0];
                        }
                        if(streets[1]!=null){
                            address.street2 = streets[1];
                        }
                        if(streets[2]!=null){
                            address.street3 = streets[2];
                        }
                    }

                    address.city = ka.OrderApi__City__c;
                    address.zip = ka.OrderApi__Postal_Code__c;

                    cmp.set("v.address", address);
                    cmp.find('country').set("v.value", address.countryCode);
                    cmp.find('state').set("v.value", address.stateCode);
                }),
                $A.getCallback(function(error){
                    // Something went wrong
                    alert('An error has occurred : ' + error.message);
                })
            );
        } else {
            var action = cmp.get("c.getPlaceId");
            action.setParams({
                "addressId" : addressId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = JSON.parse(response.getReturnValue());
                    cmp.find('autoAddress').set("v.placeId", resp.candidates[0].place_id);
                } else if (state == "INCOMPLETE"){
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



    /**
     * @purpose Gets new state list based on selected country
     * @param cmp
     * @param countryVal
     */
    getNewStatesList : function(cmp, countryVal){
        console.log('NewAddressForm getNewStatesList...');
        return new Promise(
            $A.getCallback((resolve, reject) => {
                var action = cmp.get("c.getStates");
                action.setParams({
                    "countryVal": countryVal
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        // console.log('success');
                        var data = response.getReturnValue();
                        var custs = [];
                        for (var key in data) {
                            custs.push({label: data[key], value: key});
                        }
                        cmp.set("v.stateList", custs);
                        if (custs.length == 0) {
                            cmp.set("v.address.stateCode", null);
                        }
                        resolve();
                    } else if (state === "INCOMPLETE") {
                        console.log('Incomplete Callout');
                        reject();
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " +
                                    errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                        reject();
                    }
                });
                $A.enqueueAction(action);
            }));
    },
});