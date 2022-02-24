/**
 * Created by afaf.awad on 2/17/2021.
 */

({
    doInit : function(cmp,event, helper) {
        cmp.set('v.isLoading',true);
        cmp.set('v.orderId', helper.getOrderId(cmp));
        var action = cmp.get("c.getSchedule");
        action.setParams({
            // "eventId": cmp.get("v.eventId"),
            "stepId" : cmp.get('v.stepId'),
            "orderId" : cmp.get('v.orderId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data) {
                    console.log('Schedule Data: ' + JSON.stringify(data));
                    cmp.set('v.schedule', data.schedule);
                    if(data.timeSlot) {
                        cmp.set('v.eventId', data.schedule[0].Event__c);
                        cmp.set('v.timeSlotId', data.timeSlot.Id);
                        cmp.set('v.selectedDate', data.timeSlot.Delivery_Date__c);
                        cmp.set('v.scheduleId', data.timeSlot.EC_Schedule__c);
                        cmp.set('v.moreDetails', data.docUrl);
                        helper.getAvailableTimes(cmp);
                        if(data.timeSlot.Start_Time__c) {
                            console.log('timeslot == ' + data.timeSlot.Start_Time__c);
                            cmp.set('v.selectedTime', helper.convertMiliseconds(cmp, data.timeSlot.Start_Time__c) + ' - ' + helper.convertMiliseconds(cmp, data.timeSlot.End_Time__c));
                        }
                    }
                    cmp.set('v.isLoading', false);
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


    getDateFromEvent: function (cmp, event, helper) {
        console.log('selectedDate -event' + event.getParam('date'));
        cmp.set('v.selectedDate', event.getParam('date'));
        cmp.set('v.scheduleId', event.getParam('scheduleId'));
        helper.getAvailableTimes(cmp);

    },

    handleSelectedTimeSlot: function (cmp,event,helper){
        cmp.find('errorMeg').setError('');
        console.log('time value == ' + JSON.stringify(event.getSource().get("v.value")));
        var timeValue = event.getSource().get("v.value");
        if(timeValue.marked == 'free') {
            cmp.set('v.selectedTime', event.getSource().get("v.label"));
            console.log('timeSelected = ' + cmp.get('v.selectedTime'));
        }
    },

    handleSave : function (cmp,event,helper){
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        var selectedTime = cmp.get('v.selectedTime');
        if(!selectedTime){
            cmp.find('errorMeg').setError('Select an available time slot you would like your email sent.');
        }else {
            cmp.find('errorMeg').setError('');
            var startTimeString = selectedTime.substring(0, 7);
            var endTimeString = selectedTime.substring(10, 17);

            console.log('scheduleId = ' + cmp.get('v.scheduleId'));

            var action = cmp.get("c.saveTimeSlot");
            action.setParams({
                "orderId": cmp.get('v.orderId'),
                "scheduleId": cmp.get('v.scheduleId'),
                "timeSlotId": cmp.get('v.timeSlotId'),
                "startHour": helper.getTimeInt(cmp, startTimeString, 'hour'),
                "startMin": helper.getTimeInt(cmp, startTimeString, 'minute'),
                "endHour": helper.getTimeInt(cmp, endTimeString, 'hour'),
                "endMin": helper.getTimeInt(cmp, endTimeString, 'minute'),
                "deliveryDate": cmp.get('v.selectedDate')

            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Success!');
                    helper.handleSuccess(cmp);
                    // var data = response.getReturnValue();
                    // if(data) {
                    //     console.log('Success! Saved data: ' + JSON.stringify(data));
                    // }
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
        }
    }

});