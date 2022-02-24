/**
 * Created by lauren.lezberg on 1/24/2020.
 */
({

    closeModal : function(cmp, event, helper){
        cmp.set("v.isOpen", false);
    },

    sessionDateChange : function(cmp, event, helper){
        cmp.find("sessionDate").set("v.value", cmp.get("v.sessionDate"));

    },

    handleIdChange : function(cmp, event, helper){
        console.log('idchange: ' + cmp.get("v.sessionId"));
        cmp.find('sessionForm').set("v.recordId", cmp.get("v.sessionId"));
    },

    saveSession : function(cmp, event, helper){
        console.log('saveSession....');
        event.preventDefault();


        cmp.find("hiddenStartTime").set("v.value", cmp.find("startTime").get("v.value"));
        cmp.find("hiddenEndTime").set("v.value", cmp.find("endTime").get("v.value"));

        var sessionDate = cmp.find("sessionDate").get("v.value");
        // console.log('sessionDate: ' + sessionDate);

        var timezone = $A.get("$Locale.timezone");
        // console.log('Time Zone Preference in Salesforce ORG: '+timezone);

        var evt = cmp.get("v.eventObj");
        var evtStart = new Date(evt.Start_Date__c);
        // console.log('evtStart: ' + evtStart);
        var evtEnd = new Date(evt.End_Date__c);
        // console.log('evtEnd: ' + evtEnd);

        // console.log('form sessionStart: ' + cmp.find("startTime").get("v.value") );
        var timeString = cmp.find("startTime").get("v.value").replace('Z', '') + helper.getTimezoneOffset(timezone, evtStart);
        // console.log('dateString: ' + sessionDate + ' ' + timeString);
        var sessionStart = new Date(sessionDate + ' ' + timeString);
        // console.log('sessionStart: ' + sessionStart);

        // console.log('form sessionEnd: ' + cmp.find("endTime").get("v.value") );
        timeString = cmp.find("endTime").get("v.value").replace('Z', '') + helper.getTimezoneOffset(timezone, evtStart);
        // console.log('dateString: ' + sessionDate + ' ' + timeString);
        var sessionEnd = new Date(sessionDate + ' ' + timeString);
        // console.log('sessionEnd: ' + sessionEnd);


        if (sessionStart < evtStart) {
            helper.showToast(cmp, event, 'error', 'The session must start after the start of the event.');
        } else if (sessionEnd > evtEnd) {
            helper.showToast(cmp, event, 'error', 'The session must end before the end of the event.');
        } else if (sessionStart>sessionEnd){
            helper.showToast(cmp, event, 'error', 'Please make sure the session end time is after the start time.');
        } else {
            cmp.find('sessionForm').submit();
        }

    },

    handleSubmit : function(cmp, event, helper){
        console.log('handle submit....');
        // event.preventDefault();
        //
        // var sessionDate = cmp.find("sessionDate").get("v.value");
        // console.log('sessionDate: ' + sessionDate);
        //
        // var timezone = $A.get("$Locale.timezone");
        // console.log('Time Zone Preference in Salesforce ORG :'+timezone);
        //
        // var evt = cmp.get("v.eventObj");
        // var evtStart = new Date(evt.Start_Date__c);
        // console.log('evtStart: ' + evtStart);
        // var evtEnd = new Date(evt.End_Date__c);
        // console.log('evtEnd: ' + evtEnd);
        //
        // // console.log('sessionStart: ' + cmp.find("startTime").get("v.value") );
        // var timeString = 'T' + cmp.find("startTime").get("v.value").replace('Z', '') + helper.getTimezoneOffset(timezone, evtStart);
        // var sessionStart = new Date(sessionDate + timeString);
        // console.log('sessionStart: ' + sessionStart);
        //
        // timeString = 'T' + cmp.find("endTime").get("v.value").replace('Z', '') + helper.getTimezoneOffset(timezone, evtStart);
        // var sessionEnd = new Date(sessionDate + timeString);
        // console.log('sessionEnd: ' + sessionEnd);
        //
        //
        // if (sessionStart < evtStart) {
        //     helper.showToast(cmp, event, 'error', 'The session must start after the start of the event.');
        // } else if (sessionEnd.getTime() > evtEnd.getTime()) {
        //     helper.showToast(cmp, event, 'error', 'The session must end before the end of the event.');
        // } else if (sessionStart>sessionEnd){
        //     helper.showToast(cmp, event, 'error', 'Please make sure the session end time is after the start time.');
        // } else if(sessionStart==null || sessionEnd==null){
        //     helper.showToast(cmp, event, 'error', 'Start and end times are required.');
        // } else {
        //
        //
        //
        //     var eventFields = event.getParam("fields");
        //
        //     eventFields["Start_Time__c"] = cmp.find("startTime").get("v.value");
        //     eventFields["End_Time__c"] = cmp.find("endTime").get("v.value");
        //
        //     cmp.find('sessionForm').submit(eventFields);
        // }

    },

    handleError : function(cmp,event, helper){
        var message = event.getParam("message");
        console.log('error message: ' + message);
        // console.log('error: ' + JSON.stringify(event.getParam("error")));
        // console.log('detail: ' + event.getParam("detail"));
        // console.log('output: ' + JSON.stringify(event.getParam("output")));
        // console.log('fieldErrors' + event.getParam("output").fieldErrors);
        // console.log('errors' + event.getParam("output").errors);

        helper.showToast(cmp, event, 'error', message);
    },

    handleLoad : function(cmp, event, helper){
        var startTime = cmp.find("hiddenStartTime").get("v.value");
        cmp.find("startTime").set("v.value", startTime);


        var endTime = cmp.find("hiddenEndTime").get("v.value");
        cmp.find("endTime").set("v.value", endTime);
    },

    handleSuccess : function(cmp, event, helper){
        var appEvent = $A.get("e.c:EventScheduleUpdate");
        appEvent.setParams({ "type" : 'Session' });
        appEvent.fire();
    }
})