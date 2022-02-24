/**
 * Created by afaf.awad on 1/5/2021.
 */

({

    sendReceipt : function (cmp,event,helper){
        console.log('Calling method to send receipt...');
        cmp.set("v.processing", true);
        var action = cmp.get('c.emailReceipt');
        action.setParams({
            "participantId": cmp.get('v.recordId'),
            "ccJSON" : JSON.stringify(cmp.get("v.addresses")),
            "msg" : cmp.get("v.customMessage")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(!data.error) {
                    console.log('Receipt Sent');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": data.message
                    });
                    toastEvent.fire();
                }else{
                    cmp.set('v.message', data.message);
                }
                cmp.set("v.isOpen", false);
                cmp.set("v.processing", false);
            } else if (state === "INCOMPLETE") {
                console.log('Could not get response: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get response - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get response: Unknown error");
                }
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
        var addr = cmp.find('eAddr').get("v.value");
        // console.log('addr: ' + addr);

        if(addr!=null && addr!='' && addr!=undefined) {
            if(addr.includes('@')){
                var emails = cmp.get('v.addresses');

                emails.push(addr);

                cmp.find('eAddr').set("v.value", null);

                cmp.set("v.addresses", emails);
                cmp.set("v.sendDisabled", false);
            }
        }
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
        cmp.set("v.addresses", []);
        cmp.set("v.msg", null);
    }

});