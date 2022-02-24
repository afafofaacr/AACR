/**
 * Created by lauren.lezberg on 1/2/2020.
 */
({
    doInit : function(cmp, event, helper){
        console.log('fsSelector doInit..');
        var action = cmp.get("c.getFieldSets");
        action.setParams({
            "sObjName": cmp.get("v.sObjectName")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldSetMap = response.getReturnValue();
                console.log('fieldSetMap: ' + JSON.stringify(fieldSetMap));
                cmp.set("v.allPreferences", fieldSetMap);
                var fieldSetOptions = [];
                fieldSetOptions.push({"label" : '--None--', "value" : ''});
                var fieldSets = fieldSetMap;
                for(var key in fieldSets){
                    console.log('key: ' + key);
                    var option = {"label" : key, "value" : fieldSetMap[key]};
                    fieldSetOptions.push(option);
                }
                cmp.set("v.availablePreferences", fieldSetOptions);

                if(cmp.get("v.selectedPreference")!=null){
                    helper.getFieldsInFieldset(cmp, event, cmp.get("v.selectedPreference"));
                }


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
        console.log('handle selection change...');
        helper.getFieldsInFieldset(cmp, event, cmp.get("v.selectedPreference"));
    },


})