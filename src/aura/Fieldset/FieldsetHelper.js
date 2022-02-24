/**
 * Created by lauren.lezberg on 7/17/2020.
 */
({

    getStateList : function(cmp, countryVal){ 
        var action = cmp.get("c.getStateList");
        action.setParams({
            "countryVal" : countryVal,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('roles data: ' + JSON.stringify(data));
                var custs = [];
                for (var key in data) {
                    custs.push({label: data[key], value: key});
                }
                cmp.set("v.stateList", custs);

            } else if (state === "INCOMPLETE") {
                // do something

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
    }
})