/**
 * Created by lauren.lezberg on 5/14/2020.
 */
({
    getEventId : function(cmp){
        var name ='id';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            return results[1];
        }

        return null;
    },

    completeRegistration : function(cmp, event){
        console.log("completeRegistration...");
        var contact = cmp.get("v.contactRecord");
        if(contact.Preferred_Address__c=='Business') {
            contact.MailingStreet = cmp.find("street").get("v.value");
            contact.MailingCity = cmp.find("city").get("v.value");
            contact.MailingStateCode = cmp.find("state").get("v.value");
            contact.MailingPostalCode = cmp.find("zip").get("v.value");
            contact.MailingCountryCode = cmp.find("country").get("v.value");
        } else {
            contact.OtherStreet = cmp.find("street").get("v.value");
            contact.OtherCity = cmp.find("city").get("v.value");
            contact.OtherStateCode = cmp.find("state").get("v.value");
            contact.OtherPostalCode = cmp.find("zip").get("v.value");
            contact.OtherCountryCode = cmp.find("country").get("v.value");
        }

        if(contact.OrderApi__Preferred_Email_Type__c=='Work'){
            contact.OrderApi__Work_Email__c = cmp.find('email').get("v.value");
        }else {
            contact.OrderApi__Personal_email__c = cmp.find('email').get("v.value");
        }

        contact.MobilePhone = cmp.find('MobilePhone').get("v.value");
        contact.OrderApi__Work_Phone__c = cmp.find("WorkPhone").get("v.value");
        contact.Salutation = cmp.find('salutation').get('v.value');
        contact.FirstName = cmp.find('firstName').get("v.value");
        contact.LastName = cmp.find('lastName').get("v.value");
        contact.MiddleName = cmp.find('middleName').get("v.value");
        contact.AccountId = cmp.get("v.accountId");
        contact.DonorApi__Suffix__c = cmp.find('suffix').get("v.value");
        contact.Title = cmp.find("title").get("v.value");
        contact.Highest_Degree__c = cmp.find('degree').get("v.value");
        contact.Department = cmp.find('department').get("v.value");
        contact.Primary_Research_Area_of_Expertise__c = cmp.find('primaryResearch').get("v.value");
        contact.Major_Focus__c = cmp.find('majorFocus').get("v.value");
        contact.Organ_Sites__c = cmp.find('organSites').get('v.value');
        contact.Work_Setting__c = cmp.find('workSetting').get("v.value");

        var action = cmp.get("c.registerUser");
        action.setParams({
            "contactString" : JSON.stringify(cmp.get("v.contactRecord")),
            "eventId" : this.getEventId(cmp)
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));

                if(data.success) {

                    this.sendToFreeman(cmp, data.redirectURL);
                    // if (cmp.get("v.ticketSelection") == 'free') {
                    //     if (data != null) {
                    //         window.location.href = data.redirectURL;
                    //     }
                    // } else {
                    //     //redirect to donor drive donation link
                    //     window.open(cmp.get("v.donationUrl"), "_blank");
                    //     window.location.href = data.redirectURL;
                    //
                    // }
                } else {
                    cmp.set("v.processing", false);
                    cmp.set("v.errorMsg", data.message);
                }


            } else if (state === "INCOMPLETE") {
                // do something
                console.log('incomplete callout');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        cmp.set("v.errorMsg", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    sendToFreeman : function(cmp, redirectURL){
        var action = cmp.get("c.freemanRegister");
        action.setParams({
            "contactString" : JSON.stringify(cmp.get("v.contactRecord")),
            "eventId" : this.getEventId(cmp)
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));

                if (cmp.get("v.ticketSelection") == 'free') {
                    window.location.href = redirectURL;
                } else {
                    //redirect to donor drive donation link
                    window.open(cmp.get("v.donationUrl"), "_blank");
                    window.location.href = redirectURL;

                }



            } else if (state === "INCOMPLETE") {
                // do something
                console.log('incomplete callout');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        cmp.set("v.errorMsg", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    validateInput : function(cmp){
        var isValid = true;


        var affiliation = cmp.get("v.accountId");
        if(affiliation==null || affiliation == undefined || affiliation == ''){
            isValid = false;
            var errorMsg = cmp.find('affiliation_help_msg');
            $A.util.removeClass(errorMsg, 'slds-hide');
        } else {
            cmp.set("v.contactRecord.AccountId", affiliation);
        }

        var country = cmp.find("country").get("v.value");
        if(country==null || country == undefined || country == ''){
            cmp.find('country').showHelpMessageIfInvalid();
            isValid = false;
        }

        if(cmp.get("v.stateRequired")){
            var state = cmp.find("state").get("v.value");
            if(state==null || state == undefined || state == ''){
                cmp.find('state').showHelpMessageIfInvalid();
                isValid = false;
            }
        }

        var street = cmp.find("street").get("v.value");
        if(street==null || street == undefined || street == ''){
            cmp.find('street').showHelpMessageIfInvalid();
            isValid = false;
        }

        var city = cmp.find("city").get("v.value");
        if(city==null || city == undefined || city == ''){
            cmp.find('city').showHelpMessageIfInvalid();
            isValid = false;
        }


        var email = cmp.find("email").get("v.value");
        if(email==null || email == undefined || email == ''){
            isValid = false;
            $A.util.addClass(cmp.find('email'), 'slds-has-error');
            $A.util.removeClass(cmp.find('email_help_msg'), 'slds-hide');
        }

        var salutation = cmp.find("salutation").get("v.value");
        if(salutation==null || salutation == undefined || salutation == ''){
            isValid = false;
            $A.util.addClass(cmp.find('salutation'), 'slds-has-error');
            $A.util.removeClass(cmp.find('salutation_help_msg'), 'slds-hide');
        }

        var firstName = cmp.find("firstName").get("v.value");
        if(firstName==null || firstName == undefined || firstName == ''){
            isValid = false;
            $A.util.addClass(cmp.find('firstName'), 'slds-has-error');
            $A.util.removeClass(cmp.find('firstName_help_msg'), 'slds-hide');
        }

        var lastName = cmp.find("lastName").get("v.value");
        if(lastName==null || lastName == undefined || lastName == ''){
            isValid = false;
            $A.util.addClass(cmp.find('lastName'), 'slds-has-error');
            $A.util.removeClass(cmp.find('lastName_help_msg'), 'slds-hide');
        }

        var degree = cmp.find("degree").get("v.value");
        if(degree==null || degree == undefined || degree == ''){
            isValid = false;
            $A.util.addClass(cmp.find('degree'), 'slds-has-error');
            $A.util.removeClass(cmp.find('degree_help_msg'), 'slds-hide');
        }

        var primaryResearch = cmp.find("primaryResearch").get("v.value");
        if(primaryResearch==null || primaryResearch == undefined || primaryResearch == ''){
            isValid = false;
            $A.util.addClass(cmp.find('primaryResearch'), 'slds-has-error');
            $A.util.removeClass(cmp.find('primaryResearch_help_msg'), 'slds-hide');
        }

        var majorFocus = cmp.find("majorFocus").get("v.value");
        if(majorFocus==null || majorFocus == undefined || majorFocus == ''){
            isValid = false;
            $A.util.addClass(cmp.find('majorFocus'), 'slds-has-error');
            $A.util.removeClass(cmp.find('majorFocus_help_msg'), 'slds-hide');
        }

        var organSites = cmp.find("organSites").get("v.value");
        if(organSites==null || organSites == undefined || organSites == ''){
            isValid = false;
            $A.util.addClass(cmp.find('organSites'), 'slds-has-error');
            $A.util.removeClass(cmp.find('organSites_help_msg'), 'slds-hide');
        }

        var workSetting = cmp.find("workSetting").get("v.value");
        if(workSetting==null || workSetting == undefined || workSetting == ''){
            isValid = false;
            $A.util.addClass(cmp.find('workSetting'), 'slds-has-error');
            $A.util.removeClass(cmp.find('workSetting_help_msg'), 'slds-hide');
        }

        console.log("isValid: " + isValid);

        return isValid;

    }
})