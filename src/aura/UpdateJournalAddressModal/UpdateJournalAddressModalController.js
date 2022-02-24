/**
 * Created by lauren.lezberg on 1/18/2019.
 */
({

    handleContactChange : function(cmp, event, helper){
        console.log('UpdateJournalAddressModal handleContactChange...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getJournalAddress");
        action.setParams({
            "contactId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                var custs = [];
                for (var key in data.countryList) {
                    custs.push({label: data.countryList[key], value: key});
                }
                cmp.set("v.countryList", custs);

                if (data.journalAddress != null) {
                    cmp.set("v.jAddress", data.journalAddress);
                    if(cmp.get("v.isOpen")){
                        cmp.find('newModal').set("v.addressId", data.journalAddress.Id);
                    }
                }

                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get event links: Incomplete Callout');
                cmp.set("v.isLoading", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not cancel order - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get event links: Unknown error");
                }
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);

    },

    updateAddress : function(cmp, event, helper){
        console.log('UpdateJournalAddressModal updateAddress...');
        if(cmp.get("v.isOpen")) {
            cmp.find('newModal').set("v.addressId", cmp.get("v.jAddress").Id);
        }
    },




    editAddress : function(cmp, event, helper){
        console.log('UpdateJournalAddressModal editAddress...');
        cmp.find('newModal').set("v.isOpen", true);
        cmp.find('newModal').set("v.addressId", cmp.get("v.jAddress").Id);

    },

    addAddress : function(cmp, event, helper){
        console.log('UpdateJournalAddressModal addAddress...');

        cmp.find('newModal').set("v.isOpen", true);
        cmp.find('newModal').set("v.types", ['Journal']);
        cmp.find('newModal').set("v.selectedType", 'Journal');
        cmp.find('newModal').find('type').set("v.value", 'Journal');
    },

    saveAddress : function(cmp, event, helper){
        console.log('UpdateJournalAddressModal saveAddress...');

        cmp.set("v.recordError", null);
        var action = cmp.get("c.saveJournalAddress");
        action.setParams({
            "ka" : cmp.get("v.jAddress")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data!=null) {
                    cmp.set("v.jAddress", data);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get event links: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not cancel order - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get event links: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

})