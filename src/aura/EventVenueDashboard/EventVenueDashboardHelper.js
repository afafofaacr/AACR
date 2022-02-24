/**
 * Created by afaf.awad on 5/17/2021.
 */

({
    /**
     * @purpose Get all published events for a particular month
     * @param cmp
     */
    getEventsByMonth : function(cmp){
        cmp.set("v.isLoading", true);

        var action = cmp.get("c.getEventsPerMonth");
        action.setParams({
            "month": cmp.get("v.mvalue"),
            "year" : cmp.get("v.yvalue")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data == ' + JSON.stringify(data));

                let events = data.events;
                // var help = this;
                // events.forEach(function (row){
                //     console.log('time = ' + row.Start_Date__c);
                //     row.Start_Time__c = help.convertMiliseconds(cmp,row.Start_Time__c);
                // });

                var venues = data.venues;
                var venueMap = [];

                for ( var v in venues ) {
                    var eventList = [];
                    for(var e in events) {
                        if(events[e].venueId == venues[v].Id) {
                            // console.log('event = ' + JSON.stringify(events[e]));
                            eventList.push(events[e]);

                        }
                    }
                    venueMap.push({venue: venues[v].Name, list: eventList});

                }

                // console.log('VenueMap == ' + JSON.stringify(venueMap));

                cmp.set('v.venueMap', venueMap);
                cmp.set("v.venues", data.venues);
                cmp.set("v.isLoading", false);

                console.log(' Get VenueMap == ' + JSON.stringify(cmp.get('v.venueMap')));


            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("getEventsByMonth Error - message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("getEventsByMonth Unknown error");
                }
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    convertMiliseconds: function (cmp, miliseconds) {
        var days, hours, minutes, seconds, total_hours, total_minutes, total_seconds;

        total_seconds = parseInt(Math.floor(miliseconds / 1000));
        total_minutes = parseInt(Math.floor(total_seconds / 60));
        total_hours = parseInt(Math.floor(total_minutes / 60));
        // days = parseInt(Math.floor(total_hours / 24));
        // seconds = parseInt(total_seconds % 60);
        minutes = parseInt(total_minutes % 60);
        hours = parseInt(total_hours % 24);

        minutes = minutes < 10 ? '0' + minutes : minutes;
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours > 12 ? hours - 12 : hours;
        // hours = hours < 10 ? '0' + hours : hours;

        return hours + ':' + minutes + ampm;
    },


});