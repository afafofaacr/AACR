/**
 * Created by lauren.lezberg on 3/18/2020.
 */
({
    doInit : function(cmp, event, helper){
        console.log("contactId: " + cmp.get("v.recordId"));
        var action = cmp.get("c.checkAccess");
        action.setParams({
           "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var ticketAccess = response.getReturnValue();
                console.log('ticketAccess: ' + JSON.stringify(ticketAccess));
                cmp.set("v.hasAccess", ticketAccess.hasAccess);
                cmp.set("v.disabledAccess", ticketAccess.hasDisabledAccess);
            } else if (state === "INCOMPLETE") {
                console.log('Could not check access: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not check access - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not check access: Unknown error");
                }

            }
            cmp.set("v.processing",false);
        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Create an empty open sales order and redirect user to back office ticketing process
     * @param cmp
     * @param event
     * @param helper
     */
    goToBackOfficeTicketing : function(cmp, event, helper){
        cmp.set("v.processing", true);
        var action = cmp.get("c.createBackOfficeTicketSO");
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
                console.log('Could not create sales order: Incomplete Callout');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not create sales order - Error message: " +
                            errors[0].message);
                    }
                    cmp.set("v.processing", false);
                } else {
                    console.log("Could not create sales order: Unknown error");
                    cmp.set("v.processing", false);
                }

            }
            cmp.set("v.processing",false);
        });
        $A.enqueueAction(action);
    },
})