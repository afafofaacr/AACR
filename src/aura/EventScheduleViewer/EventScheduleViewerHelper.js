/**
 * Created by lauren.lezberg on 1/13/2020.
 */
({
    getEventSchedule : function(cmp, event){
        console.log('recordId: ' + cmp.get("v.recordId"));
        var action = cmp.get("c.getEventSchedule");
        action.setParams({
            "eventId": cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                cmp.set("v.scheduleItems", data.schedule);
                cmp.set("v.eventObj", data.event);
                cmp.set("v.sessionModalOpen", false);
                cmp.set("v.speakerModalOpen", false);
                cmp.set("v.editSessionOpen", false);
                cmp.set("v.editSpeakerOpen", false);

                // this.openSessions(cmp, event);
            } else if (state === "INCOMPLETE") {
                // do something

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

    getSpeakerAssistant : function(cmp, event, contactId){
        var action = cmp.get("c.getAssistantId");
        action.setParams({
            "contactId": contactId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + data);
                cmp.find('assistantId').set("v.value", data);
            } else if (state === "INCOMPLETE") {
                // do something
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



    getCurrentDateTimeMySql : function (date) {
        var tzoffset = (date).getTimezoneOffset() * 60000; //offset in milliseconds
        var localISOTime = (new Date(date - tzoffset)).toISOString().slice(0, 19).replace('T', ' ');
        var mySqlDT = localISOTime;
        return mySqlDT;
    },

    showToast : function(component, event, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "message": message
        });
        toastEvent.fire();
    },

    openSessions : function(cmp, event){
        console.log('openSessions...');
        var data = cmp.get("v.scheduleItems");

        var accordions = cmp.find('accordion');


        if(accordions.length>0) {

            accordions.forEach(function (accordion) {
                var sections = [];
                // console.log('accordion: ' + accordion.get("v.name"));
                data.forEach(function (schedule) {
                    console.log('schedule: ' + schedule.eventDay);
                    if (schedule.eventDay == accordion.get("v.title")) {

                        schedule.sessions.forEach(function (session) {
                            sections.push(session.sessionId);
                        });


                    }

                });
                accordion.set("v.activeSectionName", sections);
            });

        }
    },

    deleteSelectedRecord : function(cmp, event){


        var action = cmp.get("c.deleteRecord");
        action.setParams({
            "recordId": cmp.get("v.selectedId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.getEventSchedule(cmp, event);
                cmp.set("v.selectedId", null);
            } else if (state === "INCOMPLETE") {
                // do something
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

})