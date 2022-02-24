/**
 * Created by lauren.lezberg on 1/2/2020.
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
                cmp.set("v.isLoading", false);
                cmp.set("v.monthEvents", data);

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
    }
})