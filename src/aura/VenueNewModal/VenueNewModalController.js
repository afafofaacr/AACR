/**
 * Created by lauren.lezberg on 3/11/2020.
 */
({

    doInit : function(cmp,event, helper){
        cmp.set("v.isOpen", true);

        var action = cmp.get("c.getData");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var countries = data.countries;
                var custs = [];
                for(var key in countries){
                    custs.push({label:countries[key], value:key});
                }
                cmp.set("v.countryList", custs);
                cmp.set("v.virtualAccess", data.virtualAccess);


            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: doInit');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);

    },

    onCountryChange : function (cmp, event, helper) {
        var changeValue = event.getSource().get("v.value");

        if(changeValue == 'US' || changeValue == 'CA'){
            cmp.set("v.stateRequired", true);
            cmp.find("countryField").set("v.value", changeValue);

            var action = cmp.get("c.getStates");
            action.setParams({
                "countryVal" : changeValue
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    var custs = [];
                    for(var key in data){
                        custs.push({label:data[key], value:key});
                    }
                    cmp.set("v.statesList", custs);

                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout: onCountryChange');
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message - onCountryChange: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error: onCountryChange");
                    }
                }
            });
            $A.enqueueAction(action);

        } else if(changeValue == null || changeValue == '') {
            cmp.set("v.stateRequired", false);
            $A.util.removeClass(cmp.find("state"), "slds-has-error");
            $A.util.addClass(cmp.find("state"), "hide-error-message");
        } else {
            cmp.set("v.stateRequired", false);
            cmp.find("countryField").set("v.value", changeValue);
        }
    },


    resubmitForm : function(cmp, event, helper){
        cmp.find("newVenueForm").submit();
    },

    venueSelected : function(cmp, event, helper){
        var value = event.getSource().get("v.value");
        cmp.set("v.venueId", value);

        var redirect = cmp.get("v.redirect");
        if(redirect == true){
            $A.get('e.force:refreshView').fire();
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": value,
                "slideDevName": "detail"
            });
            navEvt.fire();
        } else {
            cmp.set("v.isOpen", false);
        }

    },

    closeModal : function(cmp, event, helper){
        var redirect = cmp.get("v.redirect");
        if(redirect==true) {
            $A.get('e.force:refreshView').fire();
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "Venue__c"
            });
            homeEvent.fire();
        } else {
            cmp.set("v.isOpen", false);
        }
    },

    handleVenueSubmit : function(cmp, event, helper){

        event.preventDefault();

        if(cmp.get("v.venues").length == 0) {

            var eventFields = event.getParam("fields");
            if(cmp.find('state').get("v.value")!='') {
                eventFields["State__c"] = cmp.find('state').get("v.value");
                cmp.find("stateField").set("v.value", cmp.find('state').get("v.value"));
            }
            eventFields["Country__c"] = cmp.find('country').get("v.value");

            var action = cmp.get("c.validateVenue");
            action.setParams({
                "street1": eventFields["Street_1__c"],
                "street2": eventFields["Street_2__c"],
                "street3": eventFields["Street_3__c"],
                "city": eventFields["City__c"],
                "zip": eventFields["Zip__c"],
                "name": eventFields["Name"]
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if (data.length > 0) {
                        cmp.set("v.venues", data);
                    } else {
                        cmp.find("newVenueForm").submit();
                    }

                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout: handleVenueSubmit')
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message -handleVenueSubmit: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Unknown error: handleVenueSubmit");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            console.log('Save new venue anyways!');
        }
    },

    handleVenueError : function (cmp, event, helper) {
        cmp.find('notifLib').showToast({
            "title": "Could not save venue.",
            "message": event.getParam("message"),
            "variant": "error"
        });
    },

    handleVenueSuccess : function(cmp, event, helper){
        var payload = event.getParams().response;
        cmp.set("v.venueId", payload.id);

        var redirect = cmp.get("v.redirect");
        if(redirect == true){
            $A.get('e.force:refreshView').fire();
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": payload.id,
                "slideDevName": "detail"
            });
            navEvt.fire();
        } else {
            cmp.set("v.isOpen", false);
        }

    },
})