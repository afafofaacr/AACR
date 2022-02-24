/**
 * Created by lauren.lezberg on 4/15/2021.
 */

({

    doInit : function(cmp, event, helper){
        console.log('MyMembershipToolbar init...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getMembershipActions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dResponse = response.getReturnValue();
                // console.log('membershipActions: ' + JSON.stringify(dResponse));
                cmp.set("v.canCatchUp", dResponse.canCatchUp);
                cmp.set("v.canRenew", dResponse.canRenew);
                cmp.set("v.canTransfer", dResponse.canTransfer);
                cmp.set("v.canReinstate", dResponse.canReinstate);
                cmp.set("v.canRecertify", dResponse.canRecertify);
                cmp.set("v.canReinstateTransfer", dResponse.canReinstateTransfer);
                cmp.set("v.renewalsOpen", dResponse.renewalsOpen);
                cmp.set("v.pendingApproval", dResponse.pendingApproval);
                cmp.set("v.noOperations", dResponse.noOperations);
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process renewal: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not process renewal - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process renewal: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    recertify : function(cmp, event, helper){
        console.log('MyMembershipToolbar recertify...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.startRecertification");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = response.getReturnValue();
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process recertification: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not process recertification - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process recertification: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    reinstate : function(cmp, event, helper){
        console.log('MyMembershipToolbar reinstate...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.startReinstatement");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = response.getReturnValue();
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process reinstatement: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not process reinstatement - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process reinstatement: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    goToTransfer : function(cmp, event, helper){
        console.log('MyMembershipToolbar goToTransfer...');

        window.location.href = '/MembershipCategories?isTransfer=true';
    },

    catchUp : function(cmp, event, helper){
        console.log('MyMembershipToolbar catchUp...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.catchUpToCurrent");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dResponse = response.getReturnValue();
                if(dResponse!=null){
                    window.location.href = dResponse;
                } else {
                    cmp.set("v.errorMsg", 'Could not renew subscriptions through current year.');
                }

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process renewal: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not process renewal - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process renewal: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Calls apex method to renew subscriptions. Upon success, user is redirected to correct renewal process.
     * Upon failure, user receives an error message.
     * @param cmp
     * @param event
     * @param helper
     */
    renew : function(cmp, event, helper){
        console.log('MyMembershipToolbar renew...');
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.renewSubscriptions");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var dResponse = response.getReturnValue();

                //redirect to renewal process
                window.location.href = dResponse;

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not process renewal: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not process renewal - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not process renewal: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },
});