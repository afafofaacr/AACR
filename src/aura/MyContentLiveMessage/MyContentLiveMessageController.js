/**
 * Created by lauren.lezberg on 9/25/2020.
 */

({

    doInit : function(cmp, event, helper){
        console.log('doInit...');
        var action = cmp.get("c.getLiveRedirectMessage");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                cmp.set("v.isActive", data.Live_Redirect_Active__c);
                cmp.set("v.message", data.Redirect_Message__c);
                cmp.set("v.title", data.Redirect_Title__c);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve redirect message: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve redirect message - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve redirect message: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});