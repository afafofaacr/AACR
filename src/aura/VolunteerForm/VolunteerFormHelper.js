/**
 * Created by afaf.awad on 9/15/2020.
 */

({
    registerVolunteer: function (cmp, event, helper) {
        console.log('saving volunteer...');

        cmp.set('v.isLoading', true);
        var address = cmp.get('v.address');


        var name = cmp.find("conName");
        var firstName = name.get("v.firstName");
        var lastName = name.get("v.lastName");
        var salutation = name.get("v.salutation");
        
        var contact = {};
        contact.RecordTypeId = cmp.get('v.recordType');
        contact.Salutation = salutation; //cmp.find("salutation").get("v.value");
        contact.FirstName = firstName; //cmp.find('firstName').get('v.value');
        contact.LastName = lastName; //cmp.find('lastName').get('v.value');
        contact.Email = cmp.find('email').get('v.value');
        contact.HomePhone = cmp.find('phone').get('v.value');
        contact.DonorApi__Suffix__c = cmp.find('suffix').get('v.value');
        contact.MailingStreet = address.street1 + "\n" + address.street2 + "\n" + address.street3;
        contact.MailingCity = address.city;
        contact.MailingCountryCode = address.countryCode;
        contact.MailingStateCode = address.stateCode;
        contact.MailingPostalCode = address.zip;
        contact.Volunteer_For__c = cmp.find('volunteerFor').get('v.value');
        contact.Hear_About_AACR__c = cmp.find('hearAACR').get('v.value');

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
        var isValid = true;

        var email = cmp.find("email").get("v.value");
        if (email == null || email == undefined || email == '') {
            isValid = false;
            $A.util.addClass(cmp.find('email'), 'slds-has-error');
            $A.util.removeClass(cmp.find('email_help_msg'), 'slds-hide');
        }

        var name = cmp.find("conName");

        var salutation = name.get("v.salutation");
        if (salutation == null || salutation == undefined || salutation == '') {
            isValid = false;
            $A.util.addClass(name, 'slds-has-error');
            $A.util.removeClass(cmp.find('fName_help_msg'), 'slds-hide');
        }

        var firstName = name.get("v.firstName");
        if (firstName == null || firstName == undefined || firstName == '') {
            isValid = false;
            $A.util.addClass(name, 'slds-has-error');
            $A.util.removeClass(cmp.find('fName_help_msg'), 'slds-hide');
        }

        var lastName = name.get("v.lastName");
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

        // PHONE VALIDATION
        var phone = cmp.find('phone').get("v.value");
        if (phone == null || phone == undefined || phone == '') {
            isValid = false;
            $A.util.addClass(cmp.find('phone'), 'slds-has-error');
            $A.util.removeClass(cmp.find('phone_help_msg'), 'slds-hide');
        }

        //VOLUNTEER FOR VALIDATION
        var volFor = cmp.find('volunteerFor').get("v.value");
        if (volFor == null || volFor == undefined || volFor == '') {
            isValid = false;
            $A.util.addClass(cmp.find('volunteerFor'), 'slds-has-error');
            $A.util.removeClass(cmp.find('volFor_help_msg'), 'slds-hide');
        }

        console.log("isValid: " + isValid);
        return isValid;

    }
});