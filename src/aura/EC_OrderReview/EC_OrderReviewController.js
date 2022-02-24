/**
 * Created by afaf.awad on 2/24/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('doinit review...');
        cmp.set("v.isLoading", true);
        cmp.set('v.orderId', helper.getOrderId(cmp));
        cmp.set('v.status', helper.getStatus(cmp));
        var action = cmp.get("c.getReviewOrder");
        action.setParams({
            orderId: cmp.get('v.orderId'),
            stepId: cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    //set variables
                    console.log('Order Data == ' + JSON.stringify(data));
                    if(data.timeSlot) {
                        cmp.set('v.dateSlot', data.timeSlot.Delivery_Date__c);
                        cmp.set('v.timeSlot', helper.convertMiliseconds(cmp, data.timeSlot.Start_Time__c) + ' - ' + helper.convertMiliseconds(cmp, data.timeSlot.End_Time__c));
                    }
                    if(data.order.Countries__c) {
                        cmp.set('v.countries', data.order.Countries__c.split(';'));
                    }
                    if(data.order.Attendee_Type__c) {
                        cmp.set('v.attendeeTypes', data.order.Attendee_Type__c.split(';'));
                    }
                    if(data.order.Institution_Type__c) {
                        cmp.set('v.institutionTypes', data.order.Institution_Type__c.split(';'));
                    }
                    if(data.order.Degrees__c) {
                        cmp.set('v.degrees', data.order.Degrees__c.split(';'));
                    }
                    if(data.order.Organ_Sites__c) {
                        cmp.set('v.organs', data.order.Organ_Sites__c.split(';'));
                    }
                    if(data.order.Research_Area_of_Expertise__c) {
                        cmp.set('v.researches', data.order.Research_Area_of_Expertise__c.split(';'));
                    }
                    cmp.set("v.isLoading", false);

                }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
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
                    navEvt.setParams({"cmpName": 'EC_OrderScheduler'});
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
        window.location.href = '/ExhibitorDashboard';
    },

    closeWindow: function (cmp, event, helper) {
        window.close();
    },

    confirm: function (cmp, event, helper) {
        cmp.find('orderForm').submit();
    },

    handleSuccess: function (cmp, event, helper) {
        console.log('clearing last accessed step...' + cmp.get('v.stepId'));
        var action = cmp.get("c.clearLastStep");
        action.setParams({
            stepId: cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    window.location.href = '/ExhibitorDashboard';
                }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
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

    handleError: function(cmp,event,helper){
        //handle error
    }

});