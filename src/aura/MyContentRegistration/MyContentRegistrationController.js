/**
 * Created by lauren.lezberg on 4/23/2020.
 */
({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getOpenRegistrations");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                if(data!=null) {
                    cmp.set("v.registrations", data);

                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get registrations: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get registrations - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get registrations: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    registerAndRedirect : function(cmp, event, helper){
        var eventId = event.getSource().get("v.value");
        console.log('eventID: ' + eventId);

        var action = cmp.get("c.getRegisterUrl");
        action.setParams({
            'eventId' : eventId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + data);

                window.location.href = data;

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get registrations: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get registrations - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get registrations: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
})