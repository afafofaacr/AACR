/**
 * Created by lauren.lezberg on 1/30/2020.
 */
({
    /**
     * @purpose Calls apex method to determine if button should be shown based on current user and contact information
     * @param cmp
     * @param event
     * @param helper
     */
    doInit : function(cmp, event, helper) {
        console.log('ModifyMembership init...');
        cmp.set("v.processing", true);

        var action = cmp.get("c.getShowModify");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.showButton", data);
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

    goToModifyMembership : function(cmp,event, helper){
        console.log('ModifyMembership goToModifyMembership...');

        cmp.set("v.processing", true);

        var action = cmp.get("c.createModifySalesOrder");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                cmp.set("v.processing", false);

                var salesOrderId;
                var jpId;
               for(var key in data){
                   salesOrderId = key;
                   jpId = data[key];
               }

                var pageReference = {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__BAMContainer',
                    },
                    state: {
                        "c__id": jpId,
                        "c__salesOrder" : salesOrderId,
                        "c__isModify" : 'true'
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



})