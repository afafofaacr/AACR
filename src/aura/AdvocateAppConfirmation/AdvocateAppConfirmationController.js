/**
 * Created by lauren.lezberg on 7/14/2021.
 */

({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getEventInfo");
        action.setParams({
            "eventId": helper.getEventId(cmp),
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                cmp.set("v.imgURL", data.imgUrl);
                cmp.set("v.event", data.evt);
                cmp.set("v.eventDate", data.eventDates);

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

    openItemButton : function(cmp, event, helper){
        var itemId = event.getSource().get('v.value'),
            url = window.location.href;
        window.open( '/LiveEventsList?ac__id=' + itemId , '_self');
    }
});