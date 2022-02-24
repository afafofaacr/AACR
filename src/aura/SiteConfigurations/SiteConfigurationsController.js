/**
 * Created by lauren.lezberg on 9/6/2019.
 */
({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getSiteConfigs");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' , data);
                cmp.set("v.settings", data);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
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

    updateSetting : function(cmp, event, helper){
        var idx = event.getSource().get('v.value');
        helper.save(cmp, event, idx);
    },

    activateSetting : function(cmp, event, helper){
        var idx = event.getSource().get('v.value');
        idx.Is_Active__c = true;
        helper.save(cmp, event, idx);
    },

    deactivateSetting : function(cmp, event, helper){
        var idx = event.getSource().get('v.value');
        idx.Is_Active__c = false;
        helper.save(cmp, event, idx);
    }
})