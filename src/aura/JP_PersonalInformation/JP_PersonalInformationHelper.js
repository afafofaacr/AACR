/**
 * Created by lauren.lezberg on 2/27/2019.
 */
({
    getContact: function(cmp){
        console.log('JP_PersonalInformation getContact...');

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

    setLoadingWheelText : function(cmp, txtOptions){
        cmp.find('spinner').set("v.loadingText", txtOptions[1]);

        txtOptions.forEach(function(txt){
            setTimeout(function(){
                this.setLoadingWheelText(cmp, txt);
            }, 3000);
        });

    },

    handleContactAccount : function(cmp, account){
        console.log('JP_PersonalInformation handleContactAccount...');

        return new Promise(function(resolve, reject){
            var action = cmp.get("c.setContactAccount");
            action.setParams({
                "contactId" : cmp.get("v.contactRecord.Id"),
                "accountId" : account
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                   var data = response.getReturnValue();

                    resolve(data);
                }
                else {
                    reject();
                }

            });
            $A.enqueueAction(action);
        });
    },

    resetDegreesHeld : function(cmp){
        console.log('JP_PersonalInformation resetDegreesHeld...');

        //set degrees in multi-select picklist
        var availableDegrees = cmp.get("v.availableDegrees");
        var selectedDegrees = cmp.get("v.contactRecord").Degrees_Held__c;
        if(selectedDegrees!=null) {
            var selectedList = selectedDegrees.split(',');
        } else {
            selectedList = [];
        }

        cmp.find('degrees').set("v.selected", selectedList);

        availableDegrees.forEach(function (deg, idx) {
            if (selectedList.includes(deg)) {
                availableDegrees.splice(idx, 1);
            }
        });

        cmp.find('degrees').set("v.available", availableDegrees);
    },


    validate : function(cmp){
        console.log('JP_PersonalInformation validate...');
        // return new Promise(function(resolve, reject) {
            var isValid = true;

            //SALUTATION ERROR
            var salutation = cmp.find('salutation');
            var salutationVal = salutation.get("v.value");
            if (salutationVal == null || salutationVal == undefined || salutationVal == '') {
                $A.util.addClass(salutation, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(salutation, 'slds-has-error');
            }

            //FIRST NAME VALIDATION
            var firstName = cmp.find('firstName');
            var firstNameVal = firstName.get("v.value");
            if (firstNameVal == null || firstNameVal == undefined || firstNameVal == '') {
                $A.util.addClass(firstName, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(firstName, 'slds-has-error');
                // salutationError.innerHTML = '';
            }

            //DEGREES HELD VALIDATION
            var degrees = cmp.find('degrees').get("v.selected");
            if (degrees == null || degrees == undefined || degrees.length == 0) {
                $A.util.addClass(degrees, 'slds-has-error');
                cmp.find('degrees').set("v.hasError", true);
                isValid = false;
            } else {
                cmp.find('degrees').set("v.hasError", false);
                $A.util.removeClass(degrees, 'slds-has-error');
            }

            //RACE VALIDATION
            var race = cmp.find('race');
            var raceVal = race.get("v.value");
            if (raceVal == null || raceVal == undefined || raceVal == '') {
                $A.util.addClass(race, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(race, 'slds-has-error');
            }


            // //GENDER VALIDATION
            var gender = cmp.find('gender');
            var genderVal = gender.get("v.value");
            if (genderVal == null || genderVal == undefined || genderVal == '') {
                $A.util.addClass(gender, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(gender, 'slds-has-error');
            }

            console.log('isValid: ' + isValid);


            // if(!this.validateBirthdate(cmp)){
            //     isValid = false;
            // }
            //
            // if(!this.validateAddress(cmp)){
            //     isValid = false;
            // }
            //
            // if(!this.validatePhone(cmp)){
            //     isValid = false;
            // }

            // if(!this.validateEmail(cmp)){
            //     isValid = false;
            // }

        return isValid;

    },

    validateAddress : function(cmp){
        console.log('JP_PersonalInformation validateAddress...');


        return new Promise(function(resolve, reject) {
            var isValid = true;
            var addresses = cmp.find("myAddresses").get("v.addresses");
            if (addresses.length == 0) {
                cmp.find("myAddresses").set("v.errorMsg", 'You must enter at least one address.');
                isValid = false;
            }

            if(isValid){
                resolve(isValid);
            } else{
                reject(isValid);
            }

        });
    },


    verifyEmails : function(cmp){
        console.log('verifyEmails....');

        return new Promise(function(resolve, reject){
            var isValid = true;
            var action = cmp.get("c.verifyEmails");
            action.setParams({
                "workEmail": cmp.find('WorkEmail').get("v.value"),
                "personalEmail" :  cmp.find('PersonalEmail').get("v.value")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var validityMap = response.getReturnValue();
                    console.log('map: ' + JSON.stringify(validityMap));

                    if(validityMap.work!= undefined){
                        var workEmailError = cmp.find('WorkEmailError').getElement();
                        if(validityMap.work == false){
                            workEmailError.innerHTML = 'The email address you are attempting to use is invalid or unreachable. Please correct or update your email address.';
                            $A.util.addClass(cmp.find('WorkEmail'), 'slds-has-error');
                            isValid = false;
                        } else {
                            workEmailError.innerHTML = '';
                            $A.util.removeClass(cmp.find('WorkEmail'), 'slds-has-error');
                        }
                    }
                    if(validityMap.personal!= undefined) {
                        var personalEmailError = cmp.find('PersonalEmailError').getElement();
                        if (validityMap.personal == false) {
                            personalEmailError.innerHTML = 'The email address you are attempting to use is invalid or unreachable. Please correct or update your email address.';
                            $A.util.addClass(cmp.find('PersonalEmail'), 'slds-has-error');
                            isValid = false;
                        } else {
                            personalEmailError.innerHTML = '';
                            $A.util.removeClass(cmp.find('PersonalEmail'), 'slds-has-error');
                        }
                    }

                    if(isValid) {
                        resolve();
                    } else{
                        reject();
                    }
                } else {
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },

    validateEmail : function(cmp){
        console.log('JP_PersonalInformation validateEmail...');

        return new Promise(function(resolve, reject) {
            var isValid = true;

            //EMAIL VALIDATION
            var preferredEmail = cmp.get("v.emailVal");
            var workEmail = cmp.find('WorkEmail');
            var personalEmail = cmp.find('PersonalEmail');
            if (preferredEmail == 'Work' || preferredEmail == null || preferredEmail == undefined || preferredEmail == '') {
                var emailVal = workEmail.get("v.value");
                if (emailVal == null || emailVal == undefined || emailVal == '') {
                    $A.util.addClass(workEmail, 'slds-has-error');
                    $A.util.removeClass(personalEmail, 'slds-has-error');
                    isValid = false;
                } else {
                    $A.util.removeClass(workEmail, 'slds-has-error');
                    $A.util.removeClass(personalEmail, 'slds-has-error');

                }
            } else {
                var emailVal = personalEmail.get("v.value");
                if (emailVal == null || emailVal == undefined || emailVal == '') {
                    $A.util.addClass(personalEmail, 'slds-has-error');
                    $A.util.removeClass(workEmail, 'slds-has-error');
                    isValid = false;
                } else {
                    $A.util.removeClass(workEmail, 'slds-has-error');
                    $A.util.removeClass(personalEmail, 'slds-has-error');
                }
            }

            console.log('before verify : ' + isValid);

            if(isValid){
                resolve();
            } else{
                reject();
            }
        });
    },

    validatePhone : function(cmp){
        console.log('JP_PersonalInformation validatePhone...');


        return new Promise(function(resolve, reject) {
            var isValid = true;

            //PHONE VALIDATION
            var preferredPhone = cmp.get("v.phoneVal");
            var workPhone = cmp.find('WorkPhone');
            var mobilePhone = cmp.find('MobilePhone');
            var homePhone = cmp.find('HomePhone');

            if (preferredPhone == 'Work' || preferredPhone == null || preferredPhone == undefined || preferredPhone == '') {
                var phoneVal = workPhone.get("v.value");
                if (phoneVal == null || phoneVal == undefined || phoneVal == '') {
                    $A.util.addClass(workPhone, 'slds-has-error');
                    $A.util.removeClass(mobilePhone, 'slds-has-error');
                    $A.util.removeClass(homePhone, 'slds-has-error');
                    isValid = false;
                } else {
                    $A.util.removeClass(workPhone, 'slds-has-error');
                    $A.util.removeClass(mobilePhone, 'slds-has-error');
                    $A.util.removeClass(homePhone, 'slds-has-error');
                }
            } else if (preferredPhone == 'Mobile') {
                var phoneVal = mobilePhone.get("v.value");
                if (phoneVal == null || phoneVal == undefined || phoneVal == '') {
                    $A.util.addClass(mobilePhone, 'slds-has-error');
                    $A.util.removeClass(workPhone, 'slds-has-error');
                    $A.util.removeClass(homePhone, 'slds-has-error');

                    isValid = false;
                } else {
                    $A.util.removeClass(workPhone, 'slds-has-error');
                    $A.util.removeClass(mobilePhone, 'slds-has-error');
                    $A.util.removeClass(homePhone, 'slds-has-error');
                }
            } else {
                var phoneVal = homePhone.get("v.value");
                if (phoneVal == null || phoneVal == undefined || phoneVal == '') {
                    $A.util.addClass(homePhone, 'slds-has-error');
                    $A.util.removeClass(workPhone, 'slds-has-error');
                    $A.util.removeClass(mobilePhone, 'slds-has-error');
                    isValid = false;
                } else {
                    $A.util.removeClass(workPhone, 'slds-has-error');
                    $A.util.removeClass(mobilePhone, 'slds-has-error');
                    $A.util.removeClass(homePhone, 'slds-has-error');
                }

            }

            if(isValid){
                resolve();
            } else{
                reject();
            }

        });
    },

    validateBirthdate : function(cmp){
        console.log('JP_PersonalInformation validateBirthdate...');

        return new Promise(function(resolve, reject) {
            var isValid = true;
            var bDate = new Date(cmp.find("birthdate").find('year').get("v.value"), cmp.find("birthdate").find('mon').get("v.value") - 1, cmp.find("birthdate").find('day').get("v.value"));
            
            var ageDifMs = Date.now() - bDate;
            var newAgeDif = new Date(ageDifMs);
            var age = Math.abs(newAgeDif.getUTCFullYear() - 1970);
            var birthdateError = cmp.find('birthdateError').getElement();

            //check if date is valid
            if (cmp.find("birthdate").find('year').get("v.value") == '' && cmp.find("birthdate").find('mon').get("v.value") == '' && cmp.find("birthdate").find('day').get("v.value") == '') {
                $A.util.addClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                $A.util.addClass(cmp.find("birthdate").find('mon'), 'slds-has-error');
                $A.util.addClass(cmp.find("birthdate").find('day'), 'slds-has-error');
                isValid = false;
                birthdateError.innerHTML = '';
            } else if (bDate.getFullYear() != cmp.find("birthdate").find('year').get("v.value") || bDate.getMonth() != cmp.find("birthdate").find('mon').get("v.value") - 1 || bDate.getDate() != cmp.find("birthdate").find('day').get("v.value")) {
                $A.util.addClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                $A.util.addClass(cmp.find("birthdate").find('mon'), 'slds-has-error');
                $A.util.addClass(cmp.find("birthdate").find('day'), 'slds-has-error');
                birthdateError.innerHTML = 'Invalid Date';
                isValid = false;
            } else if (age > 100) {
                $A.util.addClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                birthdateError.innerHTML = 'Please check that the date is valid.';
                isValid = false;
            } else if (age < 13) {
                $A.util.addClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                birthdateError.innerHTML = 'You must be 13 years or older.';
                isValid = false;
            } else {
                $A.util.removeClass(cmp.find("birthdate").find('year'), 'slds-has-error');
                $A.util.removeClass(cmp.find("birthdate").find('mon'), 'slds-has-error');
                $A.util.removeClass(cmp.find("birthdate").find('day'), 'slds-has-error');

                birthdateError.innerHTML = '';
            }

            //do not display in directory update for underage
            if (age <= 17) {
                cmp.set("v.disableDoNotDisplay", true);
                cmp.set("v.contactRecord.Do_Not_Display_in_Directory__c", true);
            } else {
                if (cmp.get("v.disableDoNotDisplay")) {
                    cmp.set("v.disableDoNotDisplay", false);
                    cmp.set("v.contactRecord.Do_Not_Display_in_Directory__c", false);
                }
            }

            if(isValid){
                resolve();
            } else{
                reject();
            }
        });
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
})