/**
 * Created by lauren.lezberg on 2/14/2020.
 */
({
    doInit : function(cmp, event, helper){
        var speakerId = helper.getSpeakerId(cmp);
        console.log('speakerId: ' + speakerId);
        var response = helper.getResponse(cmp);
        console.log('response: ' + response);
        cmp.set("v.accepted", response);

        var action = cmp.get("c.setSpeakerResponse");
        action.setParams({
            "accepted": cmp.get("v.accepted"),
            "speakerId" : speakerId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state: ' + state);
            if (state === "SUCCESS") {
                console.log('success');
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                if (data) {
                    cmp.set("v.disclosureLink", data.disclosureLink);
                    cmp.set("v.contactId", data.contactId);
                    cmp.set("v.assistant", data.assistant);
                }


            } else if (state === "INCOMPLETE") {
                // do something
                console.log('incomplete...');
            } else if (state === "ERROR") {
                console.log('error...');
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

    goToHelpForm : function(cmp, event, helper){
        window.location.href = '/myAACRHelp';
    }


})