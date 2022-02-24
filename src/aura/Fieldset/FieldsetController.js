/**
 * Created by lauren.lezberg on 6/23/2020.
 */
({
    doInit: function(cmp, event, helper){
        console.log("fieldset doINit");
        var action = cmp.get("c.getFieldsInFieldset");
        action.setParams({
            "objectAPIName": cmp.get("v.objectAPIName"),
            "fieldsetName" : cmp.get("v.fieldsetName")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('roles data: ' + JSON.stringify(data));
                cmp.set("v.fieldList", data.fields);
                var custs = [];
                for(var key in data.countryList){
                    custs.push({label:data.countryList[key], value:key});
                }
                cmp.set("v.countryList", custs);

            } else if (state === "INCOMPLETE") {
                // do something

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

    countryChange : function(cmp, event, helper){
        console.log('countryChange...');
        var prefAddress = cmp.get("v.preferredAddress");
        var countryVal;

        if(prefAddress == 'Business'){
            countryVal = cmp.find('mailingCountry').get("v.value");
            if(cmp.find('mailingState')!=null && cmp.find("mailingState")!=undefined){
                if(countryVal=='US' || countryVal=='CA') {
                    helper.getStateList(cmp, countryVal);
                }else {
                    cmp.set("v.stateList",[]);

                }
            }
        } else if(prefAddress=='Home'){
            countryVal = cmp.find('otherCountry').get("v.value");
            if(cmp.find('otherState')!=null && cmp.find("otherState")!=undefined){
                if(countryVal=='US' || countryVal=='CA') {
                    helper.getStateList(cmp, countryVal);
                }else {
                    cmp.set("v.stateList",[]);
                }
            }
        }

    },

    handleSuccess  : function(cmp,event, helper){
        cmp.set("v.isValid", true);
    },

    handleError : function(cmp,event, helper){
        console.log('error');
    },

    handleLoad : function(cmp, event, helper){
        console.log('handle load');

            cmp.set("v.preferredAddress", cmp.find('prefAddress').get("v.value"));
            cmp.set("v.preferredPhone", cmp.find('prefPhone').get("v.value"));
            cmp.set("v.preferredEmail", cmp.find('prefEmail').get("v.value"));
            var countryVal;
            if (cmp.get("v.preferredAddress") == 'Business') {
                cmp.set("v.selectedCountry", cmp.find('MailingCountryCode').get("v.value"));
                cmp.set("v.selectedState", cmp.find('MailingStateCode').get("v.value"));
                countryVal = cmp.find('MailingCountryCode').get("v.value");
            } else {
                cmp.set("v.selectedCountry", cmp.find('OtherCountryCode').get("v.value"));
                cmp.set("v.selectedState", cmp.find('OtherStateCode').get("v.value"));

                countryVal = cmp.find('OtherCountryCode').get("v.value");
            }
            if (countryVal == 'US' || countryVal == 'CA') {
                helper.getStateList(cmp, countryVal);
            }

            // if (cmp.find("accountName").get("v.value") != null && cmp.find("accountName").get("v.value") != undefined && cmp.find("accountName").get("v.value") != '') {
            //     cmp.set("v.accountId", cmp.find('account').get('v.value'));
            //     cmp.find('affiliation').updateLookup();
            // } else {
            //     $A.util.addClass(cmp.find('affiliation'), 'slds-hide');
            // }
            cmp.set("v.isLoading", false);

    },

    saveForm : function(cmp, event, helper){
        console.log('saveFOrm....');

        var acctLookup = cmp.find('accountLookup');
        if(acctLookup!=undefined) {
            var acctId = acctLookup.get("v.selectedRecord").accountId;
            cmp.find('account').set("v.value", acctId );
        }
        var prefAddress = cmp.get("v.preferredAddress");

        if(cmp.find('country')!=undefined) {
            if(prefAddress == 'Business') {
                cmp.find('MailingCountryCode').set("v.value", cmp.find('country').get("v.value"));
            } else if(prefAddress == 'Home'){
                cmp.find('OtherCountryCode').set("v.value", cmp.find('country').get("v.value"));
            }
        } else {
            if(prefAddress == 'Business') {
                if(cmp.find('mailingCountry')!=undefined) {
                    cmp.find('MailingCountryCode').set("v.value", cmp.find('mailingCountry').get("v.value"));
                    cmp.find('MailingStateCode').set("v.value", cmp.find('mailingState').get("v.value"));
                }
            } else if(prefAddress == 'Home'){
                if(cmp.find('otherCountry')!=undefined) {
                    cmp.find('OtherCountryCode').set("v.value", cmp.find('otherCountry').get("v.value"));
                    cmp.find('OtherStateCode').set("v.value", cmp.find('otherState').get("v.value"));
                }
            }
        }

        console.log('submitting...');
        cmp.find('editForm').submit();

    }
})