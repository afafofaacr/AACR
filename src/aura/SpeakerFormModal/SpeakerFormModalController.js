/**
 * Created by lauren.lezberg on 1/23/2020.
 */
({

    handleIdChange : function(cmp, event, helper){
        cmp.find('speakerForm').set("v.recordId", cmp.get("v.speakerId"));
    },


    handleLoad: function (cmp, event, helper) {
        console.log("handle load...");

        //set start time input
        var startTime = cmp.find("hiddenTime").get("v.value");
        if(startTime!=null) {
            cmp.find("startTime").set("v.value", startTime);
        }

        //set session id
        if(cmp.get("v.sessionId")!=null) {
            cmp.find('sessionId').set('v.value', cmp.get("v.sessionId"));
        }

        // get assistants
        var contactId = cmp.find('contactId').get("v.value");
        if(contactId!=null) {
            helper.getSpeakerAssistant(cmp, event, contactId);
        } else {
            cmp.set("v.assistants", []);
        }
    },

    handleSubmit: function (cmp, event, helper) {
        console.log("handle speaker submit...");
        event.preventDefault();

        console.log('startTime: ' + cmp.find("startTime").get("v.value"));


        var eventFields = event.getParam("fields");
        eventFields["Presentation_Time__c"] = cmp.find("startTime").get("v.value");
        if(cmp.find('assistantsList')!=null && cmp.find('assistantsList')!=undefined) {
            console.log('assistant: ' + cmp.find('assistantsList').get("v.value"));
            eventFields["Assistant__c"] = cmp.find('assistantsList').get("v.value");
        }

        cmp.find('speakerForm').submit(eventFields);
    },


    handleSuccess: function (cmp, event, helper) {

        var appEvent = $A.get("e.c:EventScheduleUpdate");
        appEvent.setParams({ "type" : 'Speaker' });
        appEvent.fire();

        cmp.set("v.isOpen", false);

    },

    handleSpeakerChange : function(cmp, event, helper){
        console.log("handleSpeakerChange...");
        var speakerId = event.getSource().get("v.value");
        helper.getSpeakerAssistant(cmp, event, speakerId);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.isOpen", false);
        cmp.set("v.speakerId", null);
    }
})