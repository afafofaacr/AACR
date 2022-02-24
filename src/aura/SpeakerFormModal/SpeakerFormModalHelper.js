/**
 * Created by lauren.lezberg on 1/23/2020.
 */
({
    getSpeakerAssistant : function(cmp, event, contactId){
        var action = cmp.get("c.getAssistants");
        action.setParams({
            "contactId": contactId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + data);
                if(data!=null) {
                    cmp.set("v.assistants", data);

                    var assistantId = cmp.find('assistantId');
                    if (assistantId != null && assistantId != undefined) {
                        cmp.find('assistantsList').set("v.value", assistantId);
                    }
                }
             
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
})