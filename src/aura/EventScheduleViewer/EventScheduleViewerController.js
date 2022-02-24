/**
 * Created by lauren.lezberg on 1/10/2020.
 */
({
    doInit: function (cmp, event, helper) {
        var timezone = $A.get("$Locale.timezone");
        console.log('Time Zone Preference in Salesforce ORG :'+timezone);
        cmp.set("v.orgTimezone", timezone);
        helper.getEventSchedule(cmp, event);
    },

    handleScheduleUpdate : function(cmp, event, helper){
        helper.getEventSchedule(cmp, event);
    },
    

    openAll: function (cmp, event, helper) {
        helper.openSessions(cmp, event);
    },

    closeAll : function(cmp, event){

        // cmp.find('accordion').set("v.activeSectionName", []);
        // var data = cmp.get("v.scheduleItems");
        //
        var accordions = cmp.find('accordion');
        if(accordions.length>0) {
            accordions.forEach(function (accordion) {
                accordion.set("v.activeSectionName", []);
                // data.forEach(function (schedule) {
                //     if (schedule.eventDay == accordion.get("v.title")) {
                //         accordion.set("v.activeSectionName", []);
                //     }
                //
                // });
            });
        }
    },

    //speaker methods
    openSpeakerModal: function (cmp, event, helper) {
        console.log('open speaker modal');
        var sessionId = event.getSource().get("v.value");
        cmp.set("v.speakerModalOpen", true);
        if(sessionId!=null && sessionId!=undefined) {
            cmp.find('speakerModal').set("v.sessionId", sessionId);
        }
    },

    openEditSpeaker: function (cmp, event, helper) {
        var speakerId = event.getSource().get("v.value");
        cmp.set("v.speakerModalOpen", true);

        if(speakerId!=null) {
            cmp.find('speakerModal').set("v.speakerId", speakerId);
        }
    },

    //session methods
    openEditSession: function (cmp, event, helper) {
        var sessionId = event.getSource().get("v.value");
        cmp.set("v.sessionModalOpen", true);
        cmp.find("sessionModal").set("v.sessionId", sessionId);
    },

    openSessionModal: function (cmp, event, helper) {
        var sessionDate = event.getSource().get("v.value");
        if (sessionDate != null) {
            cmp.set("v.sessionModalOpen", true);
            cmp.find("sessionModal").set("v.sessionDate", sessionDate);
        } else {
            cmp.set("v.sessionModalOpen", true);
        }
    },



    // confirmDeleteSession : function(cmp, event, helper){
    //     console.log('confirming delete...');
    //     var selectedId = event.getSource().get('v.value');
    //     console.log('selectedId: ' + selectedId);
    //
    //     cmp.find("confirmModal").set("v.message", 'Are you sure you want to delete this session? ');
    //     cmp.find("confirmModal").set("v.isOpen", true);
    //
    //     cmp.set("v.selectedId", selectedId);
    //
    // },

    confirmDeleteRecord: function(cmp,event, helper){
        console.log('confirming delete...');
        var selectedId = event.getSource().get('v.value');
        console.log('selectedId: ' + selectedId);

        cmp.find("confirmModal").set("v.message", 'Are you sure you want to delete this record? ');
        cmp.find("confirmModal").set("v.isOpen", true);

        cmp.set("v.selectedId", selectedId);
    },

    handleResponseClick : function(cmp, event, helper){
        console.log('handleResponseClick...');

        var reject = event.getParam('reject');
        console.log('reject: ' + reject);
        var confirm = event.getParam('confirm');
        console.log('confirm: ' + confirm);

        if(confirm){
            helper.deleteSelectedRecord(cmp, event);
        }
    },






})