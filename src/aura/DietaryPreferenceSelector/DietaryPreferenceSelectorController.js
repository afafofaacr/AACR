/**
 * Created by lauren.lezberg on 12/10/2019.
 */
({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getFieldSets");
        action.setParams({
            "eventId": cmp.get("v.eventId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldSetMap = response.getReturnValue();
                cmp.set("v.allPreferences", fieldSetMap);
                var fieldSetOptions = [];
                var fieldSets = fieldSetMap;
                for(var key in fieldSets){
                    // console.log('key: ' + key);
                    var option = {"label" : key, "value" : key};
                    fieldSetOptions.push(option);
                }
                cmp.set("v.availablePreferences", fieldSetOptions);


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
    },

    handleChange : function(cmp, event, helper){
        helper.getFieldsInFieldset(cmp, event, cmp.get("v.selectedPreference"));
    },



})