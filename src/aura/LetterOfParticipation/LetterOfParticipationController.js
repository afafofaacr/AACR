/**
 * Created by afaf.awad on 9/24/2020.
 */

({
    doInit : function(cmp,event,helper){

        var action = cmp.get('c.getLOP');
        action.setParams({
            "participantId": cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var enable = response.getReturnValue();
                console.log('enable = ' + enable);
                    cmp.set('v.enable', enable);
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

    closeModal : function(cmp, event, helper){
        cmp.set("v.isOpen", false);

    },

    sendLetter : function (cmp,event,helper){
        cmp.set('v.enable', false);

        var action = cmp.get('c.sendPDF');
        action.setParams({
            "participantId": cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(!data.error) {
                    console.log('Letter Sent');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type" : "success",
                        "message": data.message
                    });
                    cmp.set('v.enable', true);
                    toastEvent.fire();
                }else{
                    cmp.set('v.enable', true);
                    cmp.set('v.message', data.message);
                    cmp.set('v.isOpen', true);
                }
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

        // var url = cmp.get('v.url');
        // if(url){
        //     window.open(url, '_blank');
        // }else{
        //     console.log('No URL');
        //     cmp.set('v.isOpen', true);
        // }
    }
});