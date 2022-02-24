/**
 * Created by lauren.lezberg on 1/6/2021.
 */

({
    getContact: function(cmp){
        // cmp.set("v.contactRecord.Id", null);
        var action = cmp.get("c.getCurrentContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue();

                if(contact.Account.Name.includes('Household')){
                    contact.is_affiliated_with_self__c = true;
                } else {
                    contact.is_affiliated_with_self__c = false;
                    cmp.set("v.accountId", contact.AccountId);
                }

                // cmp.find("displayInDirectory").set("v.checked", contact.Do_Not_Display_in_Directory__c);
                cmp.set("v.contactRecord.Do_Not_Display_in_Directory__c", contact.Do_Not_Display_in_Directory__c);

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            }
            else if (state === "ERROR") {
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


    validate : function(cmp){
        console.log('validating personal information...');
        var isValid = true;

        //SALUTATION ERROR
        var salutation = cmp.find('salutation');
        var salutationVal = salutation.get("v.value");
        // var salutationError = cmp.find('salutationError').getElement();
        if(salutationVal==null || salutationVal== undefined || salutationVal == '') {
            // $A.util.addClass(salutation, 'slds-has-error');
            // salutationError.innerHTML = 'Complete this field.';
            isValid = false;
        }
        // else {
            // $A.util.removeClass(salutation, 'slds-has-error');
            // salutationError.innerHTML = '';
        // }

        //FIRST NAME VALIDATION
        var firstName = cmp.find('firstName');
        var firstNameVal = firstName.get("v.value");
        // var fNameError = cmp.find('fNameError').getElement();
        if(firstNameVal == null || firstNameVal == undefined || firstNameVal==''){
            // $A.util.addClass(firstName, 'slds-has-error');
            // fNameError.innerHTML = 'Complete this field.';
            isValid = false;
        }
        // else{
        //     $A.util.removeClass(firstName, 'slds-has-error');
        //     fNameError.innerHTML = '';
        // }

        //DEGREES HELD VALIDATION
        var degrees = cmp.find('degrees').get("v.selected");
        console.log('degrees : ' + degrees);
        // var degreesVal= degrees.get("v.value");
        var degreeError = cmp.find('degreeError').getElement();
        if(degrees == null || degrees == undefined || degrees.length == 0 ){
            $A.util.addClass(degrees, 'slds-has-error');
            degreeError.innerHTML = 'Complete this field.';
            isValid = false;
        } else {
            $A.util.removeClass(degrees, 'slds-has-error');
            degreeError.innerHTML = '';
        }
        // if(degreesVal == null ||degreesVal == undefined || degreesVal==''){
        //     $A.util.addClass(degrees, 'slds-has-error');
        //     degreeError.innerHTML = 'Complete this field.';
        //     isValid = false;
        // } else{
        //     $A.util.removeClass(degrees, 'slds-has-error');
        //     degreeError.innerHTML = '';
        // }


        //RACE VALIDATION
        var race = cmp.find('race');
        var raceVal = race.get("v.value");
        if(raceVal == null || raceVal == undefined || raceVal==''){

            isValid = false;
        }


        // //GENDER VALIDATION
        var gender = cmp.find('gender');
        var genderVal = gender.get("v.value");
        if(genderVal == null || genderVal == undefined || genderVal==''){

            isValid = false;
        }

        if(!this.validateBirthdate(cmp)){
            isValid = false;
        }
        //
        // if(!this.validateAddress(cmp)){
        //     isValid = false;
        // }
        //
        if(!this.validateEmail(cmp)){
            isValid = false;
        }
        if(!this.validatePhone(cmp)){
            isValid = false;
        }

        return isValid;
    },

    validateAddress : function(cmp){
        var isValid = true;

        var addresses = cmp.find("myAddresses").get("v.addresses");
        if(addresses.length == 0){
            cmp.find("myAddresses").set("v.errorMsg", 'You must enter at least one address.');
            isValid = false;
        }

        return isValid;
    },

    validateEmail : function(cmp){
        var contactRecord = cmp.get("v.contactRecord");
        var isValid = true;
        //EMAIL VALIDATION
        var preferredEmail = contactRecord.OrderApi__Preferred_Email_Type__c;
        var workEmail = cmp.find('WorkEmail');
        var workError = cmp.find('WorkEmailError').getElement();
        var personalEmail = cmp.find('PersonalEmail');
        var personalError = cmp.find('PersonalEmailError').getElement();
        if(preferredEmail=='Work' || preferredEmail==null || preferredEmail==undefined || preferredEmail==''){
            var emailVal = workEmail.get("v.value");
            if(emailVal == null ||emailVal == undefined || emailVal=='') {
                $A.util.addClass(workEmail, 'slds-has-error');
                $A.util.removeClass(personalEmail, 'slds-has-error');
                workError.innerHTML = 'Complete this field.';
                personalError.innerHTML = '';
                isValid = false;
            } else {
                $A.util.removeClass(workEmail, 'slds-has-error');
                $A.util.removeClass(personalEmail, 'slds-has-error');
                workError.innerHTML = '';
                personalError.innerHTML = '';
            }
        } else {
            var emailVal = personalEmail.get("v.value");
            if(emailVal == null ||emailVal == undefined || emailVal=='') {
                $A.util.addClass(personalEmail, 'slds-has-error');
                $A.util.removeClass(workEmail, 'slds-has-error');
                personalError.innerHTML = 'Complete this field.';
                workError.innerHTML = '';
                isValid = false;
            } else {
                $A.util.removeClass(workEmail, 'slds-has-error');
                $A.util.removeClass(personalEmail, 'slds-has-error');
                workError.innerHTML = '';
                personalError.innerHTML = '';
            }
        }
        return isValid;
    },

    validatePhone : function(cmp){
        var contactRecord = cmp.get("v.contactRecord");
        var isValid = true;

        //PHONE VALIDATION
        var preferredPhone = contactRecord.OrderApi__Preferred_Phone_Type__c;
        var workPhone = cmp.find('WorkPhone');
        var workError = cmp.find('WorkPhoneError').getElement();
        var mobilePhone = cmp.find('MobilePhone');
        var mobileError = cmp.find('MobilePhoneError').getElement();
        var homePhone = cmp.find('HomePhone');
        var homeError = cmp.find('HomePhoneError').getElement();

        if(preferredPhone=='Work' || preferredPhone==null || preferredPhone==undefined || preferredPhone==''){
            var phoneVal = workPhone.get("v.value");
            if(phoneVal == null ||phoneVal == undefined || phoneVal=='') {
                $A.util.addClass(workPhone, 'slds-has-error');
                $A.util.removeClass(mobilePhone, 'slds-has-error');
                $A.util.removeClass(homePhone, 'slds-has-error');
                workError.innerHTML = 'Complete this field.';
                mobileError.innerHTML = '';
                homeError.innerHTML = '';
                isValid = false;
            } else {
                $A.util.removeClass(workPhone, 'slds-has-error');
                $A.util.removeClass(mobilePhone, 'slds-has-error');
                $A.util.removeClass(homePhone, 'slds-has-error');
                workError.innerHTML = '';
                mobileError.innerHTML = '';
                homeError.innerHTML = '';
            }
        } else if(preferredPhone == 'Mobile'){
            var phoneVal = mobilePhone.get("v.value");
            if(phoneVal == null ||phoneVal == undefined || phoneVal=='') {
                $A.util.addClass(mobilePhone, 'slds-has-error');
                $A.util.removeClass(workPhone, 'slds-has-error');
                $A.util.removeClass(homePhone, 'slds-has-error');
                mobileError.innerHTML = 'Complete this field.';
                workError.innerHTML = '';
                homeError.innerHTML = '';
                isValid = false;
            } else {
                $A.util.removeClass(workPhone, 'slds-has-error');
                $A.util.removeClass(mobilePhone, 'slds-has-error');
                $A.util.removeClass(homePhone, 'slds-has-error');
                workError.innerHTML = '';
                mobileError.innerHTML = '';
                homeError.innerHTML = '';
            }
        } else {
            var phoneVal = homePhone.get("v.value");
            if(phoneVal == null ||phoneVal == undefined || phoneVal=='') {
                $A.util.addClass(homePhone, 'slds-has-error');
                $A.util.removeClass(workPhone, 'slds-has-error');
                $A.util.removeClass(mobilePhone, 'slds-has-error');
                homeError.innerHTML = 'Complete this field.';
                workError.innerHTML = '';
                mobileError.innerHTML = '';
                isValid = false;
            } else {
                $A.util.removeClass(workPhone, 'slds-has-error');
                $A.util.removeClass(mobilePhone, 'slds-has-error');
                $A.util.removeClass(homePhone, 'slds-has-error');
                workError.innerHTML = '';
                mobileError.innerHTML = '';
                homeError.innerHTML = '';
            }

        }

        return isValid;
    },

    validateBirthdate : function(cmp){
        // var bDate = new Date(cmp.find("birthdate").get("v.value")).getTime();
        var bDate = new Date(cmp.find("birthdate").find('year').get("v.value"),cmp.find("birthdate").find('mon').get("v.value"), cmp.find("birthdate").find('day').get("v.value"));
        console.log("bDate: " + bDate);
        // var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var ageDifMs = Date.now() - bDate;
        var newAgeDif = new Date(ageDifMs);
        var age = Math.abs(newAgeDif.getUTCFullYear() - 1970);
        // var birthdate = cmp.find('birthdate');
        var birthdateError = cmp.find('birthdateError').getElement();
        // if(birthdate.get("v.value")!=null) {
            //do not display in directory update for underage

            if (age <= 17) {
                cmp.set("v.disableDoNotDisplay", true);
                cmp.set("v.contactRecord.Do_Not_Display_in_Directory__c", true);
            } else {
                if(cmp.get("v.disableDoNotDisplay")) {
                    cmp.set("v.disableDoNotDisplay", false);
                    cmp.set("v.contactRecord.Do_Not_Display_in_Directory__c", false);
                }
            }

            if (age < 13) {
                $A.util.addClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                birthdateError.innerHTML = 'You must be 13 years or older.';
                return false;
            } else {
                $A.util.removeClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                birthdateError.innerHTML = '';
                return true;
            }
        // } else {
        //     // $A.util.addClass(birthdate, 'slds-has-error');
        //     // birthdateError.innerHTML = 'Complete this field.';
        //     return false;
        // }
        return true;
    },

    getJoinId : function(cmp){
        var name ='id';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1];
        }

        return null;
    }
});