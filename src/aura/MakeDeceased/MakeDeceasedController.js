/**
 * Created by lauren.lezberg on 12/9/2019.
 */
({
    doInit: function(cmp, event, helper){

        var action = cmp.get("c.getButtonVisibility");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.showButton", data);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
            }
        });
        $A.enqueueAction(action);
    },

    /** Opens confirm modal **/
    openModal : function(cmp, event, helper){
        cmp.set("v.showModal", true);
    },

    /** Closes confirm modal **/
    closeModal : function(cmp, event, helper){
        cmp.set("v.showModal", false);
    },

    retireMembership : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.moveContactToDeceased");
        action.setParams({
            "contactId" : cmp.get("v.recordId"),
            "noteContent" : cmp.get("v.noteInfo")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                document.location.reload(true);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
            }
        });
        $A.enqueueAction(action);
    }
})