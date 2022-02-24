/**
 * Created by lauren.lezberg on 2/11/2020.
 */
({

    doInit: function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.getAllCurrentSubscriptions");
        action.setParams({
            "contactId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var subs = response.getReturnValue();
                cmp.set("v.subscriptions", subs);
                cmp.set("v.processing", false);
            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve data: Unknown error");
                }
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);

    },


    cancelSelectedSubscriptions : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.cancelSubscriptions");
        action.setParams({
            "subIds": cmp.get("v.subsToCancel")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('successfully remove subscriptions');
            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve data: Unknown error");
                }
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },

    addToCancelList : function(cmp, event, helper){
        console.log('adding to cancel list...');

        var subId = event.getSource().get("v.value");
        console.log('subscriptionId: ' + subId);

        var currentSubs = cmp.get("v.subscriptions");
        var cancelList = cmp.get("v.subsToCancel");

        //add to cancel list
        cancelList.push(subId);
        cmp.set("v.subsToCancel", cancelList);

        //remove from subscriptions list
        currentSubs.forEach(function(sub, idx){
            console.log('idx: ' + idx);
            if(sub.Id == subId){
                currentSubs.splice(idx, 1);
            }
        });
        console.log('subscriptions: ' + currentSubs);
        cmp.set("v.subscriptions", currentSubs);
    },


})