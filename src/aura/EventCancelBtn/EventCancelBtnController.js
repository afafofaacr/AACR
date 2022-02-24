/**
 * Created by lauren.lezberg on 4/15/2020.
 */
({
    doInit : function(cmp, event, helper){
        cmp.set("v.processing", true);
        console.log('recordId: ' + cmp.get("v.recordId"));
        var action = cmp.get("c.getShowButton");
        action.setParams({
            "eventId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + data);

                cmp.set("v.showButton", data);

                const rand=()=>Math.random(0).toString(36).substr(2);
                const token=(length)=>(rand()+rand()+rand()+rand()).substr(0,length);

                cmp.set("v.cmpId", token(40));

                cmp.set("v.processing", false);
            } else if (state === "INCOMPLETE") {
                // do something
                cmp.set("v.processing", false);

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
                cmp.set("v.processing", false);
            }
        });
        $A.enqueueAction(action);
    },

    startCancelProcess : function(cmp, event, helper){
        var confirm = event.getParam('confirm');
        console.log('confirm: ' + confirm);

        var cmpId = event.getParam('cmpId');
        // var globalId = cmp.getLocalId();

        if(confirm && cmpId == cmp.get("v.cmpId")) {
            cmp.set("v.processing", true);

            var action = cmp.get("c.cancelEvent");
            action.setParams({
                "eventId": cmp.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    console.log('data: ' + JSON.stringify(data));

                    var success = false;
                    var toastEvent = $A.get("e.force:showToast");
                    for (var key in data) {
                        console.log('key: ' + key);
                        if (key) {
                            success = true;
                            toastEvent.setParams({
                                "type": 'success',
                                "title": "Success!",
                                "message": "The event has been cancelled successfully."
                            });

                        } else {
                            toastEvent.setParams({
                                "type": 'error',
                                "title": "Error",
                                "message": data[key]
                            });
                        }
                    }
                    toastEvent.fire();

                    cmp.set("v.processing", false);

                    if (success) {
                        location.reload();
                        // var navEvt = $A.get("e.force:navigateToSObject");
                        // navEvt.setParams({
                        //     "recordId": cmp.get("v.recordId"),
                        //     "slideDevName": "detail"
                        // });
                        // navEvt.fire();
                        // window.location.href = 'lightning/n/AACR_Events';
                    }
                } else if (state === "INCOMPLETE") {
                    // do something
                    cmp.set("v.processing", false);

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
                    cmp.set("v.processing", false);
                }
            });
            $A.enqueueAction(action);
        }
    },

    openModal : function(cmp, event, helper){
        cmp.find('cancelConfirmModal').set("v.isOpen", true);
    }
})