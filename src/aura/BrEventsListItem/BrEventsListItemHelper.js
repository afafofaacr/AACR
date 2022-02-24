({

    rsvpItem: function(cmp, rsvpType, callback) {

        var action = cmp.get('c.rsvpEvent');

        action.setParams({
            recordId: cmp.get('v.item.item.Id'),
            rsvpType: rsvpType,
            attendeesLimit: cmp.get('v.item.item.Limit_of_attendees__c')
        });

        action.setCallback(this, function(response){
            var state = response.getState(),
                resVal = response.getReturnValue();


            if (state === 'SUCCESS') {
                if (typeof callback === 'function') {
                    callback(resVal);
                }
            }
        });

        $A.enqueueAction(action);
    },

    attendVirtualMeeting : function(cmp, eventId){
        console.log('attending virtual meeting...');
        var action = cmp.get('c.goToVirtualMeeting');

        action.setParams({
            "eventId" : eventId
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === 'SUCCESS') {
                var resVal = response.getReturnValue();
                console.log('resVal: ' + resVal);
                if(resVal!=null){
                    window.open(resVal, '_blank');
                }
            }  else if (state === "INCOMPLETE") {
                console.log('Could not retrieve cart item data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve cart item data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve cart item data: Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    },

    toggleGoingDropdown: function (cmp) {
        var goingBtn = cmp.find('dropdown-wrapper-going');
        $A.util.toggleClass(goingBtn, 'slds-is-open');
    }
})