/**
 * Created by lauren.lezberg on 4/21/2020.
 */
({


    doInit : function(cmp, event, helper){
        var recordId = cmp.get("v.recordId");
        console.log('recordId: ' + recordId);
        var action = cmp.get("c.getEventId");
        // set param to method
        action.setParams({
            'attendeeId' : recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('eventId: ' + storeResponse);
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if(storeResponse!=null) {
                    cmp.set("v.eventId", storeResponse);
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    },

    sendEmail : function(cmp, event, helper){
        var action = cmp.get("c.sendRegistrationEmail");
        // set param to method
        action.setParams({
            'eventId' : cmp.get("v.eventId"),
            'contactId' : cmp.get("v.contactId"),
            'attendeeId' : cmp.get("v.recordId")
        });
        // set a callBack
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if(storeResponse){
                    if(cmp.find('contacts')!=undefined && cmp.find("contacts")!=null) {
                        cmp.find('contacts').clearAccount();
                        cmp.find('events').clearAccount();
                    }

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'success',
                        "title": "Success!",
                        "message": "Email sent successfully!"
                    });
                    toastEvent.fire();

                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : 'error',
                        "title": "Error",
                        "message": "Error sending email."
                    });
                    toastEvent.fire();
                }
            }

        });
        // enqueue the Action
        $A.enqueueAction(action);
    }
})