/**
 * Created by lauren.lezberg on 8/8/2019.
 */
({
    /**
     * @purpose Calls apex method to determine if button should be shown based on current user and contact information
     * @param cmp
     * @param event
     * @param helper
     */
    doInit : function(cmp, event, helper){ 
        cmp.set("v.processing", true);

        var action = cmp.get("c.showNewApplicationButton");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.showButton", data);
                cmp.set("v.processing", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
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

    /**
     * @purpose Calls apex method to start a new application sales order and redirects user to BackOfficeOrder process
     * Upon failure, user receives an error toast.
     * @param cmp
     * @param event
     * @param helper
     */
    startNewApplication : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.createBackOfficeSO");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__BAMContainer',
                    },
                    state: {
                        "c__id": data.joinId,
                        "c__salesOrder" : data.salesOrderId,
                        "c__isRenew" : "false"
                    }
                };
                cmp.set("v.pageReference", pageReference);

                var navService = cmp.find("navService");
                navService.generateUrl(pageReference)
                    .then($A.getCallback(function(url) {
                        window.location.href = url;
                    }), $A.getCallback(function(error) {
                        console.log("ERROR");
                    }));
                // event.preventDefault();
                // navService.navigate(pageReference);

        } else if (state === "INCOMPLETE") {
                console.log('Could not create new application SO: Incomplete Callout');
                helper.createErrorToast(cmp, event, 'Could not create new application SO: Incomplete Callout');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not create new application SO - Error message: " +
                            errors[0].message);
                        helper.createErrorToast(cmp, event, 'Could not create new application SO - Error message:' + errors[0].message);
                    }
                    cmp.set("v.processing", false);
                } else {
                    console.log("Could not create new application SO: Unknown error");
                    helper.createErrorToast(cmp, event, 'Could not create new application SO: Unknown error');
                    cmp.set("v.processing", false);
                }

            }
            cmp.set("v.processing",false);
        });
        $A.enqueueAction(action);
    },

    cancelModal : function(cmp, event, helper){
        cmp.set("v.isMember", null);
    },

})