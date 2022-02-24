/**
 * Created by lauren.lezberg on 9/25/2020.
 */

({

    sendEmail : function(cmp, event, helper){
        var action = cmp.get("c.resendEmail");
        action.setParams({
            "participantId" : cmp.get("v.recordId"),
            "ccJSON" : JSON.stringify(cmp.get("v.addresses"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "success",
                    "title": "Success!",
                    "message": "Email sent successfully."
                });
                toastEvent.fire();
                cmp.set("v.isOpen", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error",
                    "message": "Email was not sent."
                });
                toastEvent.fire();
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
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error",
                    "message": "Email was not sent."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    validateInput : function(cmp, event, helper){
        if(cmp.find('eAddr').get("v.value")==null || cmp.find('eAddr').get("v.value")==''){
            cmp.set("v.sendDisabled", false);
        } else {
            cmp.set("v.sendDisabled", true);
        }
    },

    addToList : function(cmp, event, helper){
        var emails = cmp.get('v.addresses');
        emails.push(cmp.find('eAddr').get("v.value"));

        cmp.find('eAddr').set("v.value", null);

        cmp.set("v.addresses", emails);
        cmp.set("v.sendDisabled", false);
    },

    removeFromList : function(cmp, event, helper){
        var element = event.getSource().get("v.value");
        var emails = cmp.get('v.addresses');
        emails.forEach(function(e, idx){
            if(e==element){
                emails.splice(idx, 1);
            }
        });

        cmp.set('v.addresses', emails);
    },


    openModal : function(cmp, event, helper){
        cmp.set("v.isOpen", true);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.isOpen", false);
    }
});