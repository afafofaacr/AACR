({
    doInit: function(cmp, event, helper){
        helper.getItem(cmp, function(){
            helper.getAttendeesCount(cmp);

            if(!cmp.get('v.hideAttendees')){
                helper.getItemParticipations(cmp);
            }
        });
    },

    goToAddToCalendar : function(cmp, event, helper){
        var eventId = event.getSource().get("v.value");
        window.open("/AddToCalendar?id=" + eventId, "_blank");
    },

    attendMeeting : function(cmp,event, helper){
        var eventId = event.getSource().get("v.value");
        helper.attendVirtualMeeting(cmp, eventId);
    },

    redirect : function(cmp, event, helper){
        var redirectUrl = event.getSource().get("v.value");

        window.open(redirectUrl, '_blank');
    },

    downloadInvitePDF : function(cmp, event, helper){
        var action = cmp.get('c.getInviteToDownload');
        action.setParams({
            "eventId": cmp.get('v.id')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var url = response.getReturnValue();
                window.open(url, '_blank');
            } else if (state === "INCOMPLETE") {
                console.log('Could not get response: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get response - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get response: Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    downloadPDF : function(cmp, event, helper){
        var action = cmp.get('c.getLetterToDownload');
        action.setParams({
            "eventId": cmp.get('v.id')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var url = response.getReturnValue();
                window.open(url, '_blank');
            } else if (state === "INCOMPLETE") {
                console.log('Could not get response: Incomplete Callout');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get response - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get response: Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    rsvpItem: function(cmp, event, helper) {
        var targetEl = event.currentTarget,
            rsvpType = targetEl.dataset.type,
            errEvt;

        helper.rsvpItem(cmp, rsvpType, function(newAttendeesCount) {
            if (newAttendeesCount !== 'error' && newAttendeesCount !== 'auth_required' && newAttendeesCount !== 'limit_exceded') {

                cmp.set('v.attendeesCount', newAttendeesCount);
                helper.getItemParticipations(cmp);

                var goingBtnYesItem = cmp.find('goingBtnYesItem'),
                    goingBtnNoItem = cmp.find('goingBtnNoItem'),
                    goingBtn2YesItem = cmp.find('goingBtn2YesItem'),
                    goingBtn2NoItem = cmp.find('goingBtn2NoItem');

                if(rsvpType === 'Yes'){
                    cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_going"));
                    $A.util.addClass(goingBtnYesItem, 'slds-is-selected');
                    $A.util.removeClass(goingBtnNoItem, 'slds-is-selected');
                    $A.util.addClass(goingBtn2YesItem, 'slds-is-selected');
                    $A.util.removeClass(goingBtn2NoItem, 'slds-is-selected');
                } else if(rsvpType === 'No'){
                    cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_not_going"));
                    $A.util.addClass(goingBtnNoItem, 'slds-is-selected');
                    $A.util.removeClass(goingBtnYesItem, 'slds-is-selected');
                    $A.util.addClass(goingBtn2NoItem, 'slds-is-selected');
                    $A.util.removeClass(goingBtn2YesItem, 'slds-is-selected');
                } else{
                    cmp.set('v.rsvpStatus', $A.get("$Label.c.lbl_are_u_going"));
                }


            } else if (newAttendeesCount === 'auth_required') {
                errEvt = cmp.getEvent('eventsErrorEvent');
                errEvt.setParams({'type':'auth_required', 'message':$A.get("$Label.c.msg_authorization_required")});
                errEvt.fire();
            } else if (newAttendeesCount === 'limit_exceded') {
                errEvt = cmp.getEvent('eventsErrorEvent');
                errEvt.setParams({'type':'limit_exceded', 'message':$A.get("$Label.c.msg_attendees_limit_exceded")});
                errEvt.fire();
            } else {
                //TODO: handle error
            }
        });
        helper.toggleGoingDropdown(cmp);
    },

    toggleGoingDropdown: function (cmp, event, helper) {
        helper.toggleGoingDropdown(cmp);
    },

    openAttendeesList: function (cmp) {
        cmp.set('v.showAttendeesList', true);
    },
    openAttendeesListModal: function (cmp) {
        cmp.set('v.showAttendeesModal', true);
    },

    closeAttendeesListModal: function (cmp) {
        cmp.set('v.showAttendeesModal', false);
    },
    hideAttendeesList: function (cmp) {
        cmp.set('v.showAttendeesList', false);
    },

    backToList: function (cmp) {
        window.location.href = '/LiveEventsList';
        // var urlEvent = $A.get("e.force:navigateToURL");
        // var url = window.location.origin + window.location.pathname;
        //
        // urlEvent.setParams({
        //     "url": url
        // });
        //
        // urlEvent.fire();
    },

    onDateChange: function (cmp, event) {
        var urlEvent = $A.get("e.force:navigateToURL"),
            url = window.location.origin + window.location.pathname;

        var date = event.getParam('date');

        if (date != null && date !== '') {
            if (url.indexOf('?') > -1) {
                url += '&';
            } else {
                url += '?';
            }

            url += 'ac__date=' + event.getParam('date');
        }

        urlEvent.setParams({
            "url": url
        });

        urlEvent.fire();
    }
})