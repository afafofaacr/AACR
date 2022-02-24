/**
 * Created by lauren.lezberg on 5/18/2021.
 */

({
    doInit : function(cmp, event, helper){
        console.log('LifetimeConverterButton init...');

        var action = cmp.get("c.getVisibility");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var showBtn = response.getReturnValue();
                cmp.set("v.showButton", showBtn);

                const rand=()=>Math.random(0).toString(36).substr(2);
                const token=(length)=>(rand()+rand()+rand()+rand()).substr(0,length);

                cmp.set("v.cmpId", token(40));
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get button visibility: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get button visibility - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get button visibility: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    openModal : function(cmp, event, helper){
        console.log('LifetimeConverterButton openModal...');

        cmp.find("confirmModal").set("v.message", 'Are you sure you want to convert this member to a Lifetime member? ');
        cmp.find("confirmModal").set("v.isOpen", true);
    },

    convertSubscription : function(cmp, event, helper){
        console.log('LifetimeConverterButton convertSubscription...');

        var action = cmp.get("c.doConversion");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                document.location.reload(true);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not convert subscription: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not convert subscription - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not convert subscription: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});