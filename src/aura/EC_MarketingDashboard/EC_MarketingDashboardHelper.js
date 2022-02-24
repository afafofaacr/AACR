/**
 * Created by afaf.awad on 3/1/2021.
 */

({    /**
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

                var help = this;
                data.forEach(function (row){
                    console.log('time = ' + row.Start_Time__c);
                    row.Start_Time__c = help.convertMiliseconds(cmp,row.Start_Time__c);
                });

                cmp.set("v.schedule", data);
                cmp.set("v.isLoading", false);


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


    // getRowActions: function (cmp, row, doneCallback) {
    //     var actions = [];
    //
    //     if (row.Status__c == 'Incomplete') {
    //         actions.push({
    //             'label': 'Continue',
    //             // 'iconName': 'utility:edit_form',
    //             'name': 'continue'
    //         });
    //         // deleteAction.disabled = 'true';
    //     }
    //     actions.push({
    //         'label': 'Delete',
    //         // 'iconName': 'utility:delete',
    //         'name': 'delete'
    //     });
    //
    //     // simulate a trip to the server
    //     setTimeout($A.getCallback(function () {
    //         doneCallback(actions);
    //     }), 200);
    // },

});