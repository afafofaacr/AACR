/**
 * Created by afaf.awad on 3/2/2021.
 */

({
    doInit : function(cmp,event, helper) {
        cmp.set('v.isLoading',true);
        var orderId = helper.getOrderId(cmp);
        cmp.set('v.orderId', orderId);
        var action = cmp.get("c.getEmailRecord");
        action.setParams({
            "orderId": orderId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                if(data) {
                    cmp.set('v.emailId', data.Id);
                    cmp.set('v.isLoading',false);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Error: Incomplete callout.");
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

    goPrevious: function (cmp, event, helper) {
        console.log('stepid : ' + cmp.get('v.stepId') );
        var action = cmp.get("c.getPreviousStep");
        action.setParams({
            stepId: cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stepId = response.getReturnValue();
                if (stepId) {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": stepId});
                    navEvt.setParams({"cmpName": 'EC_ReviewEmail'});
                    navEvt.fire();
                }
            } else if (state === "INCOMPLETE") {
                console.log('State is Incomplete');
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

    cancelOrder: function (cmp, event, helper) {
        helper.goBackToOrder(cmp);
    },

    approveReject : function(cmp,event,helper) {
        cmp.set('v.processing', true);
        console.log('orderId == ' + cmp.get('v.orderId'));
        var button = event.getSource().getLocalId(); //clicked approve or reject button
        cmp.set('v.decision', button);
        cmp.find('emailForm').submit(); //save comments first

    },


    handleSuccess : function(cmp,event,helper){
            //Email requester and go back to order record
            var action = cmp.get("c.approveRejectOrder");
            action.setParams({
                "orderId": cmp.get('v.orderId'),
                "decision": cmp.get('v.decision')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    console.log('isSuccess: ' + JSON.stringify(data));
                    if(data.isSuccess) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: "success",
                            title: 'Success!',
                            message: 'Email has been sent.',
                            duration: ' 3000',
                        });
                        toastEvent.fire();
                        helper.goBackToOrder(cmp);
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type: "error",
                            title: 'Failed Validation',
                            message: data.message,
                            mode : 'sticky',
                            key: 'info_alt',
                        });
                        toastEvent.fire();
                        helper.goBackToOrder(cmp);
                    }
                } else if (state === "INCOMPLETE") {
                    cmp.set('v.processing',false);
                    console.log("Error: Incomplete callout.");
                } else if (state === "ERROR") {
                    cmp.set('v.processing',false);
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

});