/**
 * Created by lauren.lezberg on 9/6/2019.
 */
({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getDirectorySettingsData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' , data);
                cmp.set("v.launchData", data.launchData);
                cmp.set("v.directoryCriteria", data.directoryCriteria);
            }
            else if (state === "INCOMPLETE") {
                // do something
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

    updateDisplayCriteria : function(cmp, event, helper){
        var action = cmp.get("c.saveDirectoryCriteria");
        action.setParams({
            "record" : cmp.get("v.directoryCriteria")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Your request has been sent. You can check the status of this job from Setup > Deployment Status ",
                    "type" : "success"
                });
                toastEvent.fire();
                setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 5000);
            }
            else if (state === "INCOMPLETE") {
                // do something
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

    updateLaunchData : function(cmp, event, helper){
        var recordId = event.getSource().get("v.value");
        var recordToUpdate = {};
        cmp.get("v.launchData").forEach(function(record){
           if(record.Id == recordId){
               recordToUpdate = record;
           }
        });
        var action = cmp.get("c.saveDirectoryLaunchData");
        action.setParams({
            "record" : recordToUpdate
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "Your request has been sent. You can check the status of this job from Setup > Deployment Status ",
                    "type" : "success"
                });
                toastEvent.fire();
                setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 5000);
            }
            else if (state === "INCOMPLETE") {
                // do something
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