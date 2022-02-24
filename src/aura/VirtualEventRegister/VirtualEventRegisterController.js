/**
 * Created by lauren.lezberg on 5/14/2020.
 */
({
    doInit : function(cmp, event, helper){
        console.log('doInit...');
        var action = cmp.get("c.getEventRegInfo");
        action.setParams({
            "eventId" : helper.getEventId(cmp)
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));

                cmp.set("v.headerImg", data.headerImgURL);
                cmp.set("v.logoImg", data.regImgURL);
                cmp.set("v.freeTxt", data.freeTicketText);
                cmp.set("v.donationTxt", data.donationTicketText);
                cmp.set("v.donationUrl", data.donationURL);
                cmp.set("v.exhibitOpen", data.exhibitOpen);


                var contact = data.con;

                var cData = data.countryMap;
                var custs = [];
                for(var key in cData){
                    custs.push({label:cData[key], value:key});
                }
                cmp.set("v.countryList", custs);

                var sData = data.stateMap;

                if(sData!=null && sData!=undefined) {
                        var states = [];
                        for (var s in sData) {
                            states.push({label: sData[s], value: s});
                        }
                        cmp.set("v.displayStateList", states);
                }


                cmp.set("v.contactRecord", contact);
                cmp.set("v.contactId", contact.Id);
                console.log("contactId: " + cmp.get("v.contactId"));

                if(contact.MailingCountryCode == 'US' || contact.MailingCountryCode == 'CA'){
                    cmp.set("v.stateRequired", true);
                }


                //set picklists
                cmp.find("degree").set("v.value", contact.Highest_Degree__c);
                cmp.find("primaryResearch").set("v.value", contact.Primary_Research_Area_of_Expertise__c);
                cmp.find("workSetting").set("v.value", contact.Work_Setting__c);

                if(contact.Account.Name.includes('Household')){
                    contact.is_affiliated_with_self__c = true;

                } else {
                    contact.is_affiliated_with_self__c = false;
                    cmp.set("v.accountId", contact.AccountId);
                    cmp.find("affiliation").updateLookup();
                }



            } else if (state === "INCOMPLETE") {
                console.log('incomplete callout');

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

    onCountryChange : function(cmp, event, helper){
        var changeValue = event.getSource().get("v.value");
        console.log('changeValue: ', changeValue);
        if(changeValue == null || changeValue == '') {
            $A.util.removeClass(cmp.find("state"), "slds-has-error");
            $A.util.addClass(cmp.find("state"), "hide-error-message");
        }

        if (changeValue == 'US' || changeValue == 'CA'){
            cmp.set('v.stateRequired', true);
        } else {
            cmp.set("v.stateRequired", false);
        }


        var action = cmp.get("c.getStates");
        action.setParams({
            "countryVal" : changeValue
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('states: ', data);
                var custs = [];
                for(var key in data){
                    custs.push({label:data[key], value:key});
                }
                cmp.set("v.displayStateList", custs);

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

    handleFieldUpdate : function(cmp, event, helper){
        var fieldId = event.getSource().get("v.id");
        console.log("fieldId: " + fieldId);
        if(cmp.find(fieldId).get('v.value')==null || cmp.find(fieldId).get("v.value")==undefined){
            $A.util.addClass(cmp.find(fieldId), 'slds-has-error');
            $A.util.removeClass(cmp.find(fieldId + '_help_msg'), 'slds-hide');
        } else {
            $A.util.removeClass(cmp.find(fieldId), 'slds-has-error');
            $A.util.addClass(cmp.find(fieldId + '_help_msg'), 'slds-hide');
        }
    },

    handleAccountChange : function(cmp, event, helper){
        var accountId = event.getParam("value");
        console.log('accountId: ' + accountId);
        if(accountId!=null){
            var errorMsg = cmp.find('affiliation_help_msg');
            $A.util.addClass(errorMsg, 'slds-hide');
        }
    },

    selectFreeTicket : function(cmp, event, helper){
        cmp.set("v.ticketSelection", 'free');
    },

    selectDonationTicket : function(cmp, event, helper){
        if(cmp.get("v.exhibitOpen")){
            cmp.set("v.ticketSelection", 'free');
        } else {
            cmp.set("v.ticketSelection", 'donation');
        }
    },

    openDonation : function(cmp, event, helper){
        window.open(cmp.get("v.donationUrl"), "_blank");
        window.location.href = '/VirtualRegisterConfirmation?id=' + helper.getEventId(cmp);
    },

    cancelReg: function(cmp, event, helper){
        window.location.href='/MemberProfile';
    },


    saveContactInfo : function(cmp, event, helper){
        console.log('saving contact info...');
        event.preventDefault();

        cmp.set("v.processing", true);
        var isValid = helper.validateInput(cmp);
        if(isValid) {
            helper.completeRegistration(cmp, event);
            // cmp.find('recordEditForm').submit();
        } else {
            cmp.set("v.processing", false);
        }

    },

})