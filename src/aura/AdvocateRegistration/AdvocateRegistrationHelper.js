/**
 * Created by afaf.awad on 9/21/2020.
 */

({
    registerAdvocate: function (cmp, event) {
        cmp.set('v.isLoading', true);
        var address = cmp.get('v.address');


        var name = cmp.find("conName");
        var firstName = name.get("v.firstName");
        var lastName = name.get("v.lastName");
        var salutation = name.get("v.salutation");

        console.log ('name ==' + salutation + ' ' + firstName +' '+ lastName);

        var contact = {};
        contact.RecordTypeId = cmp.get('v.recordType');
        contact.accountId = cmp.get('v.accountId');
        contact.Salutation = salutation; //cmp.find("salutation").get("v.value");
        contact.FirstName = firstName; //cmp.find('firstName').get('v.value');
        contact.LastName = lastName; //cmp.find('lastName').get('v.value');
        contact.Email = cmp.find('email').get('v.value');
        contact.Title = cmp.find('title').get('v.value');
        contact.HomePhone = cmp.find('phone').get('v.value');
        contact.DonorApi__Suffix__c = cmp.find('suffix').get('v.value');
        contact.MailingStreet = address.street1 + "\n" + address.street2 + "\n" + address.street3;
        contact.MailingCity = address.city;
        contact.MailingCountryCode = address.countryCode;
        contact.MailingStateCode = address.stateCode;
        contact.MailingPostalCode = address.zip;
        contact.Primary_Stakeholder__c = cmp.find('primaryStakeholder').get('v.value');
        contact.Secondary_Stakeholder__c = cmp.find('secondaryStakeholder').get('v.value');

        var action = cmp.get("c.saveVolunteer");
        action.setParams({
            "contactString": JSON.stringify(contact)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.success) {
                    console.log('Success! ' + JSON.stringify(data.message));
                    window.open('https://' + cmp.get('v.domain') + '/apex/RegConfirmation','_self');
                    cmp.set('v.isSuccess', true);
                    cmp.set('v.isLoading', false);
                } else {
                    cmp.set("v.isLoading", false);
                    console.log('failed to insert: ', JSON.stringify(data.message));
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
            }

        });
        $A.enqueueAction(action);
    },

    validateInput: function (cmp) {
        console.log('validating...');
        var isValid = true;

        var email = cmp.find("email").get("v.value");
        if (email == null || email == undefined || email == '') {
            isValid = false;
            $A.util.addClass(cmp.find('email'), 'slds-has-error');
            $A.util.removeClass(cmp.find('email_help_msg'), 'slds-hide');
        }
        //
        // var salutation = cmp.find("salutation").get("v.value");
        // if (salutation == null || salutation == undefined || salutation == '') {
        //     isValid = false;
        //     $A.util.addClass(cmp.find('salutation'), 'slds-has-error');
        //     $A.util.removeClass(cmp.find('salutation_help_msg'), 'slds-hide');
        // }

        var name = cmp.find("conName");
        // name.get("v.lastName");

        var firstName = name.get("v.firstName");
            //cmp.find("firstName").get("v.value");
        if (firstName == null || firstName == undefined || firstName == '') {
            isValid = false;
            $A.util.addClass(name, 'slds-has-error');
            $A.util.removeClass(cmp.find('fName_help_msg'), 'slds-hide');
        }

        var lastName = name.get("v.lastName");
        //cmp.find("firstName").get("v.value");
        if (lastName == null || lastName == undefined || lastName == '') {
            isValid = false;
            $A.util.addClass(name, 'slds-has-error');
            $A.util.removeClass(cmp.find('fName_help_msg'), 'slds-hide');
        }

        // var lastName = cmp.find("lastName").get("v.value");
        // if (lastName == null || lastName == undefined || lastName == '') {
        //     isValid = false;
        //     $A.util.addClass(cmp.find('lastName'), 'slds-has-error');
        //     $A.util.removeClass(cmp.find('lName_help_msg'), 'slds-hide');
        // }

        if(!this.validateAddress(cmp)){
            isValid = false;
        }

        // PHONE VALIDATION
        // var phone = cmp.find('phone').get("v.value");
        // if (phone == null || phone == undefined || phone == '') {
        //     isValid = false;
        //     $A.util.addClass(cmp.find('phone'), 'slds-has-error');
        //     $A.util.removeClass(cmp.find('phone_help_msg'), 'slds-hide');
        // }

        //PRIMARY STAKEHOLDER FOR VALIDATION
        // var volFor = cmp.find('primaryStakeholder').get("v.value");
        // if (volFor == null || volFor == undefined || volFor == '') {
        //     isValid = false;
        //     $A.util.addClass(cmp.find('primaryStakeholder'), 'slds-has-error');
        //     $A.util.removeClass(cmp.find('pStake_help_msg'), 'slds-hide');
        // }

        console.log("isValid: " + isValid);
        return isValid;

    },

    validateAddress : function(cmp){
        var isValid = true;

        console.log('validating address...');
            //ADDRESS VALIDATION
            var address = cmp.get("v.address");

                if (address.countryCode == 'US' || address.countryCode == 'CA'){
                    if(address.stateCode == null || address.stateCode == undefined || address.stateCode == '') {
                        var state = cmp.find('mailingAddress').find("state");
                        state.set("v.validity",{valid:false, badInput: true});
                        state.showHelpMessageIfInvalid();
                        isValid = false;
                    }
                }

                var mailingAddress = cmp.find('mailingAddress');

                $A.util.removeClass(mailingAddress.find("street1"), "slds-has-error");
                $A.util.addClass(mailingAddress.find("street1"), "hide-error-message");

                $A.util.removeClass(mailingAddress.find("city"), "slds-has-error");
                $A.util.addClass(mailingAddress.find("city"), "hide-error-message");

                $A.util.removeClass(mailingAddress.find("country"), "slds-has-error");
                $A.util.addClass(mailingAddress.find("country"), "hide-error-message");


            if(address.street1 == null || address.street1 == undefined || address.street1==''){
                var street1 = mailingAddress.find("street1");
                street1.set("v.validity",{valid:false, badInput: true});
                street1.showHelpMessageIfInvalid();
                isValid = false;
            }
            if(address.city == null || address.city == undefined || address.city == ''){
                var city = mailingAddress.find("city");
                city.set("v.validity",{valid:false, badInput: true});
                city.showHelpMessageIfInvalid();
                isValid = false;
            }
            if(address.countryCode == null || address.countryCode == undefined || address.countryCode== ''){
                var country = mailingAddress.find("country");
                country.set("v.validity",{valid:false, badInput: true});
                country.showHelpMessageIfInvalid();
                isValid = false;
            } else if (address.countryCode == 'US' || address.countryCode == 'CA'){
                if(address.stateCode == null || address.stateCode == undefined || address.stateCode == '') {
                    var state = mailingAddress.find("state");
                    state.set("v.validity",{valid:false, badInput: true});
                    state.showHelpMessageIfInvalid();
                    isValid = false;
                }
            }
            return isValid;

    },
});