/**
 * Created by lauren.lezberg on 7/15/2021.
 */

({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getButtonVisibility");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.showButton", data);

            } else if (state === "INCOMPLETE") {
                console.log('Could not get button visibility: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get button visibility - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get button visibility: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleApproval : function(cmp, event, helper){
        var action = cmp.get("c.approveAdvocate");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");

                if(data){
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been updated successfully.",
                        "type" : "success"
                    });
                } else {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Could not approve advocate member.",
                        "type" : "error"
                    });
                }
                toastEvent.fire();

                setTimeout(function(){cmp.set("v.reviewOpen", false); }, 5000);

            } else if (state === "INCOMPLETE") {
                console.log('Could not get button visibility: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get button visibility - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get button visibility: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleRejection : function(cmp, event, helper){
        var action = cmp.get("c.rejectAdvocate");
        action.setParams({
            "contactId": cmp.get("v.recordId"),
            "rejectMsg" : cmp.find('rejectMsg').get("v.value")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                if(data){
                    cmp.set("v.reviewOpen", false);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Could not complete advocate rejection.",
                        "type" : "error"
                    });
                    toastEvent.fire();
                }

            } else if (state === "INCOMPLETE") {
                console.log('Could not get button visibility: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get button visibility - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get button visibility: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    openReviewModal : function(cmp,event, helper){
        cmp.set("v.reviewOpen", true);
        helper.getAdvocateData(cmp);
    },

    closeModal : function (cmp, event, helper){
        cmp.set("v.reviewOpen", false);
    }
});