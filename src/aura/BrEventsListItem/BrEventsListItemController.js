({
    openItem: function(cmp, event) {
        console.log("open item: ");

        var targetEl = event.currentTarget,
            itemId = targetEl.dataset.id,
            isCommunity = cmp.get('v.isCommunity');

        console.log('itemId: ' + itemId);
        console.log('isCommunity: ' + isCommunity);

        if(!isCommunity){
            var evt = cmp.getEvent('eventsOpenItemEvent');
            evt.setParam('itemId', itemId);
            evt.fire();
        }
    },

    openItemButton: function (cmp,event){

        var itemId = event.getSource().get('v.value'),
            isCommunity = cmp.get('v.isCommunity'),
            url = window.location.href;

        console.log('itemId: ' + itemId);
        console.log('isCommunity: ' + isCommunity);

        if(isCommunity){
            window.open( url + '?ac__id=' + itemId , '_self');
        }else{
            var evt = cmp.getEvent('eventsOpenItemEvent');
            evt.setParam('itemId', itemId);
            evt.fire();
        }

    },

    attendMeeting : function(cmp, event, helper){
        console.log('attendnig meeting...');
        var eventId = event.getSource().get("v.value");
        console.log("eventId: " + eventId);
        helper.attendVirtualMeeting(cmp, eventId);
    },

    rsvpItem: function(cmp, event, helper) {
        var targetEl = event.currentTarget,
            rsvpType = targetEl.dataset.type,
            errEvt;

        helper.rsvpItem(cmp, rsvpType, function(newAttendeesCount) {
            if (newAttendeesCount !== 'error' && newAttendeesCount !== 'auth_required' && newAttendeesCount !== 'limit_exceded') {

                helper.toggleGoingDropdown(cmp);
                cmp.set('v.item.attendeesCount', newAttendeesCount);
                cmp.set('v.rsvpType', rsvpType);

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
    },

    toggleGoingDropdown: function (cmp, event, helper) {
        helper.toggleGoingDropdown(cmp);
    }
})