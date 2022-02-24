/**
 * Created by lauren.lezberg on 3/29/2021.
 */

({
    doInit : function(cmp, event){
        console.log('ORCIDLinkBtn init...');

        var action = cmp.get("c.checkORCID");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var hasId = response.getReturnValue();
                cmp.set("v.hasId", hasId);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get auth url: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get auth url - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get auth url: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    linkToORCID : function(cmp, event){
        console.log('ORCIDLinkBtn linkToORCID...');

        var p = cmp.get("v.parent");
        p.saveContact();
        var action = cmp.get("c.getVerifyURL");
        action.setParams({
            "redirectURI" : window.location.href
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var redirectURL = response.getReturnValue();
                window.location.href = redirectURL;
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get auth url: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get auth url - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get auth url: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});