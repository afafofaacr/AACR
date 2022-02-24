/**
 * Created by lauren.lezberg on 3/3/2020.
 */
({
    doInit : function(cmp, event, helper){
        console.log('doInit...');
        var eventId = helper.getEventId();
        cmp.set("v.eventId", eventId);

        var action = cmp.get("c.getInviteConfirmInfo");
        action.setParams({
            "eventId": eventId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // cmp.set("v.templateBody", data.templateBody);
                cmp.set("v.speakers", data);
                cmp.find("emailPreview").refreshPreview();
            } else if (state === "INCOMPLETE") {
                console.log("error: incomplete callout");
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

    sendInvites : function(cmp, event, helper) {

        console.log('eventIdAttribute: ' + cmp.get("v.eventId"));

        var speakerIds = [];

        var speakers = cmp.get("v.speakers");
        cmp.get("v.speakers").forEach(function(speaker){
            speakerIds.push(speaker.Id);
        });

        var action = cmp.get("c.sendSpeakerInvitations");
        action.setParams({
            "eventIdString" : cmp.get("v.eventId"),
            "speakerIds" : speakerIds
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success');
                var navService = cmp.find("navService");

                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        objectApiName: 'BR_Event__c',
                        actionName: 'view',
                        recordId: cmp.get("v.eventId")
                    }
                };
                cmp.set("v.pageReference", pageReference);

                navService.navigate(pageReference);

            } else if (state === "INCOMPLETE") {
                console.log("error: incomplete callout");
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

    cancelProcess : function(cmp, event, helper){
        window.history.back();
    },

    handleSave : function(cmp, event, helper){
        console.log('handleSave...');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId" : stepId});
        navEvt.setParams({"cmpName" : cmpName});
        navEvt.fire();
    }
})