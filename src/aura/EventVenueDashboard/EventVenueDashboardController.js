/**
 * Created by afaf.awad on 5/17/2021.
 */

({
    doInit: function(cmp, event, helper){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getAvailableYears");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var currentYear = new Date().getFullYear();
                var years = [];
                data.forEach(function(d){
                    years.push({label:d, value: d});
                });
                cmp.set("v.yvalue", currentYear);
                cmp.set("v.years", years);

                var month = new Date().getMonth() + 1;
                cmp.set("v.mvalue",month.toString());
                helper.getEventsByMonth(cmp);
                // cmp.set("v.isLoading", false);

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

    changeYear : function(cmp, event, helper){
        cmp.set("v.isLoading", true);
        var newYear = event.getSource().get("v.value");
        cmp.set("v.yvalue", newYear);
        helper.getEventsByMonth(cmp);
    },

    goToNew : function(cmp, event, helper){
        cmp.set("v.openNew", true);
    },

    changeMonth : function(cmp, event, helper){
        console.log('month changing...');
        cmp.set("v.isLoading", true);
        helper.getEventsByMonth(cmp);
    },

    toggleExhibit : function(cmp, event, helper){
        var action = cmp.get("c.updateExhibit");
        action.setParams({
            "detailsId" : event.getSource().get("v.value")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              helper.getEventsByMonth(cmp);

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getZone");
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
});