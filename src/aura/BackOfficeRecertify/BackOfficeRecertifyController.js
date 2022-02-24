/**
 * Created by lauren.lezberg on 5/12/2021.
 */

({
    doInit : function(cmp, event, helper){
        console.log('BackOfficeRecertify init...');

        var action = cmp.get("c.getRecertifyInfo");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                cmp.set("v.showButton", data.showRecertButton);
                cmp.set("v.joinId", data.joinId);

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not create renewal SO: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not create renewal SO - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not create renewal SO: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Calls apex method to create a renewal sales order for the given contact
     * @param cmp
     * @param event
     * @param helper
     */
    createRecertSalesOrder : function(cmp, event, helper){
        console.log('BackOfficeRecertify createRecertSalesOrder...');

        cmp.set("v.processing", true);
        var action = cmp.get("c.processROERenew");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data!=null) {
                    if (data.isSuccess) {
                        var pageReference = {
                            type: 'standard__component',
                            attributes: {
                                componentName: 'c__BAMContainer',
                            },
                            state: {
                                "c__id": cmp.get("v.joinId"),
                                "c__salesOrder" : data.record.Id,
                                "c__isRenew" : "true"
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

                    } else {
                        helper.createErrorToast(cmp, event, data.message);
                    }
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not create renewal SO: Incomplete Callout');
                helper.createErrorToast(cmp, event, 'Could not create renewal SO: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not create renewal SO - Error message: " +
                            errors[0].message);
                        helper.createErrorToast(cmp, event, 'Could not create renewal SO -' + errors[0].message);
                    }
                } else {
                    console.log("Could not create renewal SO: Unknown error");
                    helper.createErrorToast(cmp, event, 'Could not create renewal SO: Unknown error.');
                }

            }
            cmp.set("v.processing",false);
        });
        $A.enqueueAction(action);
    }
});