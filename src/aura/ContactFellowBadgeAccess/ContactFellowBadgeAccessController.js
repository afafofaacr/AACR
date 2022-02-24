/**
 * Created by afaf.awad on 9/2/2020.
 */

({
    doInit : function(cmp, event, helper){
        helper.getFellowBadgeInfo(cmp, event);
    },

    toggleFellowAccess : function(cmp, event, helper){
        var val  = cmp.get("v.radioValue");
        var action;
        if(val == 'revoke'){
            action = cmp.get("c.revokeFellowForContact");
        } else {
            action = cmp.get("c.enableFellowForContact");
        }
        action.setParams({
            "contactId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!response.getReturnValue()){
                    conosle.log('response == ' + response.getReturnValue);
                    cmp.set("v.errorMsg", val=='revoke'?'An error occurred while deactivating this AACR Fellow badge. Please contact your salesforce administrator.':'An error occurred while activating this AACR Fellow badge. Please contact your salesforce administrator.');
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.errorMsg", val=='revoke'?'An error occurred while deactivating this AACR Fellow badge. Please contact your salesforce administrator.':'An error occurred while activating this AACR Fellow badge. Please contact your salesforce administrator.');
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

    enableFellow : function(cmp, event, helper){
        var action = cmp.get("c.enableFellowForContact");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("successfully created badge");
                if(!response.getReturnValue()){
                    cmp.set("v.errorMsg", 'An error occurred while creating AACR Fellow badge. Please contact your salesforce administrator.');
                } else {
                    helper.getFellowBadgeInfo(cmp, event);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
    }
});