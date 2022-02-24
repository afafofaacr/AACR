/**
 * Created by lauren.lezberg on 1/6/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('initializing personalInfo... ');
        var action = cmp.get("c.getPersonalInfo");
        action.setParams({
            "joinId": helper.getJoinId(cmp)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var personalInfo = response.getReturnValue();

                var contact = personalInfo.currentContact;
                if (contact.Account.Name.includes('Household')) {
                    contact.is_affiliated_with_self__c = true;
                } else {
                    contact.is_affiliated_with_self__c = false;
                    cmp.set("v.accountId", contact.AccountId);
                }

                var selectedAccount = {};
                selectedAccount.accountId = contact.AccountId;
                selectedAccount.accountName = contact.Account.Name;
                selectedAccount.isSuggested = false;
                cmp.set("v.selectedAccount", selectedAccount);

                cmp.set("v.contactRecord", contact);
                cmp.set("v.disableDoNotDisplay", personalInfo.disableDoNotDisplay);
                cmp.set("v.hideDoNotDisplay", personalInfo.hideDoNotDisplay);

                cmp.set("v.isLoading", false);

                //set degrees in multi-select picklist
                var availableDegrees = personalInfo.degreesHeldValues;
                console.log('available: ' + availableDegrees);
                var selectedDegrees = contact.Degrees_Held__c;
                var selectedList = selectedDegrees.split(',');
                console.log('selectedList: ' + selectedList);
                cmp.find('degrees').set("v.selected", selectedList);

                availableDegrees.forEach(function (deg, idx) {
                    if (selectedList.includes(deg)) {
                        // console.log('foujnd element!');
                        availableDegrees.splice(idx, 1);
                    }
                });

                cmp.find('degrees').set("v.available", availableDegrees);

                var types = ['Other'];
                if(personalInfo.addresses.length>0){
                    var hasBusiness, hasPersonal, hasJournal = false;

                    personalInfo.addresses.forEach(function(add){
                        if(add.OrderApi__Is_Default__c){
                            cmp.set("v.primaryAddress", add);
                        }
                        if (add.Type__c == 'Business') {
                            hasBusiness = true;
                        }
                        if (add.Type__c == 'Personal') {
                            hasPersonal = true;
                        }
                        if (add.Type__c == 'Journal') {
                            hasJournal = true;
                        }
                    });
                    if (!hasBusiness) {
                        types.push('Business');
                    }
                    if (!hasPersonal) {
                        types.push('Personal');
                    }
                    if (!hasJournal) {
                        types.push('Journal');
                    }
                } else {
                    types.push('Business');
                    types.push('Personal');
                    types.push('Journal');
                }

                cmp.find('myAddresses').find('addressForm').set("v.types", types);


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

    resetContact: function (cmp, event, helper) {
        helper.getContact(cmp);
    },

    // primaryAddressChange : function(cmp, event, helper){
    //     var primaryAddress = event.getSource().get('v.value');
    //     cmp.set("v.contactRecord.Preferred_Address__c", primaryAddress);
    //     helper.validateAddress(cmp);
    // },

    primaryPhoneChange: function (cmp, event, helper) {
        var primaryPhone = event.getSource().get('v.value');
        cmp.set("v.contactRecord.OrderApi__Preferred_Phone_Type__c", primaryPhone);
        helper.validatePhone(cmp);
    },

    primaryEmailChange: function (cmp, event, helper) {
        var primaryEmail = event.getSource().get('v.value');
        cmp.set("v.contactRecord.OrderApi__Preferred_Email_Type__c", primaryEmail);
        helper.validateEmail(cmp);
    },

    birthdateValidation: function (cmp, event, helper) {
        var validateBday = helper.validateBirthdate(cmp, event);
        console.log('bDate: ', validateBday);
    },

    handleSave: function (cmp, event, helper) {
        console.log('saving personal information...');
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        if (helper.validate(cmp)) {
            var contact = cmp.get("v.contactRecord");

            console.log('cmp is valid...');
            //save record edit form fields

            //DEGREES
            var selectedDegrees = cmp.find('degrees').get("v.selected");
            var selectedDegreesString = '';
            selectedDegrees.forEach(function (deg, idx) {
                if (idx != selectedDegrees.length - 1 && selectedDegrees.length > 1) {
                    selectedDegreesString += deg + ',';
                } else {
                    selectedDegreesString += deg;
                }
            });
            cmp.find('degreesHeld').set("v.value", selectedDegreesString);

            //PHONE, EMAIL, ETC.
            cmp.find('pPhone').set("v.value", contact.OrderApi__Preferred_Phone_Type__c);
            cmp.find('pEmail').set("v.value", contact.OrderApi__Preferred_Email_Type__c);
            cmp.find('dnd').set("v.value", contact.Do_Not_Display_in_Directory__c);

            //BIRTHDATE
            var bDate = $A.localizationService.formatDate(new Date(cmp.find("birthdate").find('year').get("v.value"), cmp.find("birthdate").find('mon').get("v.value"), cmp.find("birthdate").find('day').get("v.value")), "YYYY-MM-DD");
            cmp.find('bDay').set("v.value", bDate);


            var selectedAcc = cmp.find('accountLookup').find('companyLookup').get("v.selectedRecord");
            console.log('account: ' + JSON.stringify(selectedAcc));
            cmp.find('acc').set("v.value", selectedAcc.accountId);

            //TODO: add address

            cmp.set("v.isLoading", true);

            // cmp.find('recordEditForm').submit();

        } else {
            console.log('ERROR: Data is not valid.');
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }
    },

    handleSuccess: function (cmp, event, helper) {
        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();
    },

    handleError: function (cmp, event, helper) {
        var stepId = cmp.get("v.nextStepId");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

    validateEmail: function (cmp, event, helper) {
        helper.validateEmail(cmp);
    },

    validatePhone: function (cmp, event, helper) {
        helper.validatePhone(cmp);
    },

    validateSalutation: function (cmp) {
        var salutation = cmp.find('salutation');
        var salutationVal = salutation.get("v.value");
        var salutationError = cmp.find('salutationError').getElement();
        if (salutationVal != null) {
            $A.util.removeClass(salutation, 'slds-has-error');
            salutationError.innerHTML = '';
        }
    },

    validateDegrees: function (cmp) {
        var degrees = cmp.find('degrees');
        var degreesVal = degrees.get("v.value");
        var degreeError = cmp.find('degreeError').getElement();
        if (degreesVal != null) {
            $A.util.removeClass(degrees, 'slds-has-error');
            degreeError.innerHTML = '';
        }
    },

    validateGender: function (cmp) {
        var gender = cmp.find('gender');
        var genderVal = gender.get("v.value");
        var genderError = cmp.find('genderError').getElement();
        if (genderVal != null) {
            $A.util.removeClass(gender, 'slds-has-error');
            genderError.innerHTML = '';
        }
    },

    validateRace: function (cmp) {
        var race = cmp.find('race');
        var raceVal = race.get("v.value");
        var raceError = cmp.find('raceError').getElement();
        if (raceVal != null) {
            $A.util.removeClass(race, 'slds-has-error');
            raceError.innerHTML = '';
        }
    },

    validateInput: function (cmp, event, helper) {
        //helper.validate(cmp);
    },
});