/**
 * Created by lauren.lezberg on 12/7/2018.
 */
({
    doInit: function(cmp, event, helper){
        //get if approve should show -> membership is unapproved record type & they have a valid subscription
        var action = cmp.get("c.getButtonVisibility");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.showApprove", data.showApprove);
                cmp.set("v.showResign", data.showResign);
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

    approveMembership : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.approveMember");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
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
    },

    resignMembership : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.resignMember");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
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