/**
 * Created by lauren.lezberg on 9/10/2020.
 */

({
    getValidAddresses : function(cmp, event){
        console.log('MyAddresses getValidAddresses...');

        var action = cmp.get("c.getAddresses");
        action.setParams({
            "contactId" : cmp.get("v.contactId"),
            "accountId" : cmp.get("v.accountId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                var types = ['Other'];
                if(storeResponse.addresses.length>0) {
                    var hasBusiness, hasPersonal, hasJournal = false;
                    storeResponse.addresses.forEach(function (add) {
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

                cmp.find('newModal').set("v.types", types);

                cmp.set("v.addresses", storeResponse.addresses);
                var custs = [];
                for(var key in storeResponse.countries){
                    custs.push({label:storeResponse.countries[key], value:key});
                }
                cmp.set("v.countryList", custs);

                cmp.set("v.errorMsg", null);
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
        $A.enqueueAction(action);
    }
});