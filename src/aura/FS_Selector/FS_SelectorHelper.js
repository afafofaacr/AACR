/**
 * Created by lauren.lezberg on 1/2/2020.
 */
({
    getFieldsInFieldset: function(cmp, event, selectedOptionValue){ 
        var action = cmp.get("c.getFieldsInFieldset");
        action.setParams({
            "sObjName": cmp.get("v.sObjectName"),
            "fieldsetName" : selectedOptionValue
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldList = response.getReturnValue();
                cmp.set("v.FSfields", fieldList);
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



        // console.log("allPreferences: " + JSON.stringify(cmp.get("v.allPreferences")));
        // var fieldSets = cmp.get("v.allPreferences");
        // // console.log('selectedOptionValue: ' + JSON.stringify(selectedOptionValue));
        // for(var key in fieldSets){
        //     // console.log('key: ' + key);
        //     if(selectedOptionValue!=null) {
        //         if (key.toString() == selectedOptionValue.toString()) {
        //             // console.log('found selected option: ' + fieldSets[key]);
        //             cmp.set("v.FSfields", fieldSets[key]);
        //         }
        //     }
        // }
    }
})