/**
 * Created by lauren.lezberg on 2/16/2021.
 */

({

    doInit: function (cmp, event, helper) {
        var action = cmp.get("c.createCFSalesOrder");
        action.setParams({
            "eventId": helper.getEventId(cmp)
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.registered) {
                    window.location.href = '/LiveEventsList?ac__id=' + helper.getEventId(cmp);
                } else {
                    cmp.find('reg').find('register').set("v.checked", true);
                    cmp.find('reg').find('register').set("v.disabled", true);
                    $A.util.removeClass(cmp.find('reg').find('resumePanel'), 'slds-hide');
                    cmp.find('reg').set("v.eventId", helper.getEventId(cmp));
                    cmp.find('reg').set("v.salesOrderId", data.salesOrderId);
                    cmp.find('reg').set("v.contactId", data.contactId);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:doInit');
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

    processSalesOrder: function (cmp, event, helper) {
            console.log('processing salesorder....');
            var action = cmp.get("c.processTicket");
            action.setParams({
                "salesOrderId": cmp.find('reg').get("v.salesOrderId")
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // cmp.set('v.isLoading', false);
                    console.log('success');
                    window.location.href = '/LiveEventsList?ac__id=' + helper.getEventId(cmp);
                } else if (state === "INCOMPLETE") {
                    // cmp.set('v.isLoading', false);
                    console.log('Incomplete Callout:doInit');
                } else if (state === "ERROR") {
                    // cmp.set('v.isLoading', false);
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

    cancelRegistration: function (cmp, event, helper) {
        window.location.href = '/MemberProfile';
    },

    register: function (cmp, event, helper) {
            var navEvt = $A.get("e.c:JP_StepChangeEvt");
            navEvt.setParams({"stepId": cmp.find('reg').set("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
    }
});