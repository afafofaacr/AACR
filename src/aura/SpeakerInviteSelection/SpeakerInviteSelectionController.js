/**
 * Created by lauren.lezberg on 2/14/2020.
 */
({

    doInit : function(cmp, event, helper){
        console.log('doInit...');
        var eventId = helper.getEventId(cmp);

        var action = cmp.get("c.getSpeakers");
        action.setParams({
            "eventId": eventId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //set speakers
                cmp.set("v.speakers", data);

                //get count of invited speakers
                var count = 0;
                data.forEach(function(speaker){
                    if(speaker.sendInvite){
                        count += 1;
                    }
                });

                //set invite count
                cmp.set("v.inviteCount", count);

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

    updateInviteCount : function(cmp,event, helper){
        var count = cmp.get("v.inviteCount");
        var speakerId = event.getSource().get("v.value");
        var val = event.getSource().get("v.checked");
        var speakers = cmp.get("v.speakers");

        speakers.forEach(function(speaker){
            if(speaker.id == speakerId){
                speaker.includeAssistant = val;
            }
        });

        if(val == true){
            count = count + 1;
        } else {
            count = count - 1;
        }

        cmp.set("v.inviteCount", count);
        cmp.set("v.speakers", speakers);

    },

    handleSave : function(cmp, event, helper){
        console.log('handleSave...');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        //get all invitees that have sendInvite checkbox checked
        var invitees = [];
        cmp.get("v.speakers").forEach(function(speaker){
            if(speaker.sendInvite) {
                invitees.push(speaker);
            }
        });

        //set all speakers to pending
        var action = cmp.get("c.setSpeakersToPending");
        action.setParams({
            "speakerString": JSON.stringify(invitees)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //if complete, move forward
                if(data){
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId" : stepId});
                    navEvt.setParams({"cmpName" : cmpName});
                    navEvt.fire();
                } else { //if failed, stay on same page
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId" : cmp.get("v.stepId")});
                    navEvt.setParams({"cmpName" : null});
                    navEvt.fire();
                }
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


})