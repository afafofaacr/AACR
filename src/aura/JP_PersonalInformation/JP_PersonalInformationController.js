/**
 * Created by lauren.lezberg on 2/25/2019.
 */
({
    doInit: function (cmp, event, helper) {
        console.log('JP_PersonalInformation init...');
        var action = cmp.get("c.getPersonalInfo");
        action.setParams({
            "joinId": helper.getJoinId(cmp)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var personalInfo = response.getReturnValue();

                var contact = personalInfo.currentContact;
                if (contact.Account.Name.includes('Household') || contact.Account.Name.includes('Individual')) {
                    contact.is_affiliated_with_self__c = true;
                } else {
                    contact.is_affiliated_with_self__c = false;
                    cmp.set("v.accountId", contact.AccountId);
                }

                //set selected account
                var selectedAccount = {};
                selectedAccount.accountId = contact.AccountId;
                selectedAccount.accountName = contact.Account.Name;
                selectedAccount.isSuggested = false;
                cmp.set("v.selectedAccount", selectedAccount);

                cmp.set("v.accountId", contact.AccountId);

                cmp.set("v.contactRecord", contact);
                if (contact.OrderApi__Preferred_Email_Type__c != 'Work' && contact.OrderApi__Preferred_Email_Type__c != null) {
                    cmp.set("v.emailVal", contact.OrderApi__Preferred_Email_Type__c);
                } else {
                    cmp.set("v.emailVal", 'Work');
                }


                if (contact.OrderApi__Preferred_Phone_Type__c == 'Mobile' && contact.MobilePhone == null) {
                    cmp.set("v.phoneVal", 'Work');
                } else {
                    cmp.set("v.phoneVal", contact.OrderApi__Preferred_Phone_Type__c);
                }

                cmp.set("v.disableDoNotDisplay", personalInfo.disableDoNotDisplay);
                cmp.set("v.hideDoNotDisplay", personalInfo.hideDoNotDisplay);

                cmp.set("v.isLoading", false);

                cmp.set("v.availableDegrees", personalInfo.degreesHeldValues);
                //set degrees in multi-select picklist
                helper.resetDegreesHeld(cmp);

                var types = ['Other'];
                if (personalInfo.addresses.length > 0) {
                    cmp.set("v.hasAddress", true);
                    var hasBusiness, hasPersonal, hasJournal = false;
                    personalInfo.addresses.forEach(function (add) {
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

                cmp.find('pPhone').set("v.value", 'Work');


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

    goToMyAddresses: function (cmp, event, helper) {
        console.log('JP_PersonalInformation goToMyAddresses...');
        window.open('/UpdateAddressInformation', '_blank');

    },

    updateAddress: function (cmp, event, helper) {
        console.log('JP_PersonalInformation updateAddress...');
        if (cmp.find('myAddresses').get("v.addresses").length > 0) {
            cmp.set("v.hasAddress", true);
        }

    },

    handleAccountChange: function (cmp, event, helper) {
        console.log('JP_PersonalInformation handleAccountChange...');
        var acc = event.getParam("value");
        if (acc.accountId != null) {
            cmp.set("v.accountId", acc.accountId);
            cmp.set("v.hasAddress", true);
        } else {
            cmp.set("v.accountId", null);
        }
    },


    resetContact: function (cmp, event, helper) {
        console.log('JP_PersonalInformation resetContact...');

        helper.getContact(cmp);
    },

    primaryEmailChange: function (cmp, event, helper) {
        console.log('JP_PersonalInformation primaryEmailChange...');

        helper.validateEmail(cmp);
    },

    primaryPhoneChange: function (cmp, event, helper) {
        console.log('JP_PersonalInformation primaryPhoneChange...');

        helper.validatePhone(cmp);
    },

    birthdateValidation: function (cmp, event, helper) {
        console.log('JP_PersonalInformation birthdateValidation...');

        var validateBday = helper.validateBirthdate(cmp, event);
    },


    // handleSave : function(cmp, event, helper){
    //     helper.validateForm(cmp)
    //         .then($A.getCallback(function () {
    //             console.log('resolved');
    //
    //         }))
    //         .catch($A.getCallback(function () {
    //             console.log('ERROR');
    //         }));
    // },

    handleSave: function (cmp, event, helper) {
        console.log('JP_PersonalInformation handleSave...');

        //set loading wheel loop
        cmp.set('v.isLoading', true);
        cmp.find('spinner').set("v.loadingText", 'Validating form...');
        const items = ['Verifying email..', 'Saving...'];
        let i = 0;
        var interval = setInterval(() => {
            cmp.find('spinner').set("v.loadingText", items[i]);
            i += 1;
            if (i >= items.length) {
                clearInterval(interval)
            }
        }, 3000);

        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);


        if (helper.validate(cmp)) {

            helper.validateAddress(cmp)
                .then(function (result) {
                    console.log('addresses valid: ' + result);
                    if(result) {
                        return helper.validateBirthdate(cmp);
                    }
                })
                .then(function () {
                    return helper.validatePhone(cmp);
                })
                .then(function () {
                    return helper.validateEmail(cmp);
                })
                .then(function(){
                    return helper.verifyEmails(cmp);
                })
                .then(function () {

                        var contact = cmp.get("v.contactRecord");
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
                        cmp.find('pPhone').set("v.value", cmp.get("v.phoneVal"));
                        cmp.find('pEmail').set("v.value", cmp.get("v.emailVal"));
                        cmp.find('dnd').set("v.value", contact.Do_Not_Display_in_Directory__c);

                        //BIRTHDATE
                        var day = cmp.find("birthdate").find('day').get("v.value");
                        // console.log('day: ' + day);
                        var bDate = $A.localizationService.formatDate(new Date(cmp.find("birthdate").find('year').get("v.value"), cmp.find("birthdate").find('mon').get("v.value") - 1, cmp.find("birthdate").find('day').get("v.value")), "YYYY-MM-DD");
                        cmp.find('bDay').set("v.value", bDate);


                        //ACCOUNT
                        var aLookup = cmp.find('accountLookup');
                        var accountId = null;
                        // console.log('s Account: ' + aLookup);
                        if (aLookup != null) {
                            var cLookup = aLookup.find('companyLookup');
                            if (cLookup != null) {
                                var selectedAcc = cLookup.get("v.selectedRecord");
                                accountId = selectedAcc.accountId;
                                // cmp.find('acc').set("v.value", selectedAcc.accountId);
                            }
                        }
                        // console.log('accountId: ' + accountId);



                    //set and/or create new account
                        helper.handleContactAccount(cmp, accountId)

                            .then($A.getCallback(function (data) {
                                // cmp.find('acc').set("v.value", data);

                                cmp.set("v.isLoading", true);
                                cmp.find('recordEditForm').submit();

                            }))
                            .catch($A.getCallback(function () {
                                cmp.set('v.isLoading', false);
                            }));

                })
                .catch(function () {
                    console.log('ERROR: Data is not valid.');
                    cmp.set('v.isLoading', false);
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": cmp.get("v.stepId")});
                    navEvt.setParams({"cmpName": null});
                    navEvt.fire();
                })
        } else {
            console.log('ERROR: Data is not valid.');
            cmp.set('v.isLoading', false);
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }
    },

    handleSuccess: function (cmp, event, helper) {
        console.log('JP_PersonalInformation handleSuccess...');
        cmp.set("v.isLoading", true);

        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();

    },

    handleError: function (cmp, event, helper) {
        console.log('JP_PersonalInformation handleError...');
        cmp.set("v.isLoading", false);

        var errors = event.getParams();
        console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.stepId");

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

    // validateInput: function (cmp, event, helper) {
    //     //helper.validate(cmp);
    // },

})