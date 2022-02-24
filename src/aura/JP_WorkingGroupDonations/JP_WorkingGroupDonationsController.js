/**
 * Created by lauren.lezberg on 8/23/2019.
 */
({
    doInit : function(cmp, event, helper){ 
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getWorkingGroupDonationItems");
        action.setParams({
            "salesOrderId" : helper.getSalesOrderId(cmp),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var donations = [];
                data.forEach(function(wg){
                    var donation = {};
                    donation.name= wg.workingGroupName;
                    donation.description = wg.description;

                    var items = [];
                    //add zero dollar donation item
                    items.push({label : '$0', value : '0'});
                    //add all working group donation items for each working group
                    wg.donationItems.forEach(function(dItem){
                        if(wg.selectedId==null && dItem.OrderApi__Price__c == 25.00){
                            wg.selectedId = dItem.Id;
                        }
                        var radioOption = {label : '$' + dItem.OrderApi__Price__c, value : dItem.Id};
                        items.push(radioOption);
                    });

                    donation.selected = wg.selectedId;
                    donation.items = items;
                    donations.push(donation);
                });

                cmp.set("v.workingGroups", donations);
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
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
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Response to join process StepChange event. Consolidates all working group donation selections that are not $0 and calls apex method to add sales order lines
     * Upon success, user is redirected forward or backward in join process. Upon failure, user stays on same page and receives javascript alert with error
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave: function (cmp, event, helper) {
        cmp.set("v.isLoading", true);
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if(cmp.get("v.workingGroups").length>0) {
            var selected = [];

            //Limitation of cmp.find(), if there is more than 1 donation item, treat as a list. Else treat as single element.
            if (cmp.find("donationItems").length > 1) {
                cmp.find("donationItems").forEach(function (item) {
                    if(item.get("v.value")!='0') {
                        selected.push(item.get("v.value"));
                    }
                })
            } else {
                if(cmp.find("donationItems").get("v.value")!='0') {
                    selected.push(cmp.find("donationItems").get("v.value"));
                }
            }

            var action = cmp.get("c.saveWorkingGroupDonations");
            action.setParams({
                "salesOrderId": helper.getSalesOrderId(cmp),
                "selectedDonations": selected
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if (data) {
                        var navEvt = $A.get("e.c:JP_NavigateEvt");
                        navEvt.setParams({"stepId": stepId});
                        navEvt.setParams({"cmpName": cmpName});
                        navEvt.fire();
                    } else {
                        var navEvt = $A.get("e.c:JP_NavigateEvt");
                        navEvt.setParams({"stepId": cmp.get("v.stepId")});
                        navEvt.setParams({"cmpName": null});
                        navEvt.fire();
                        cmp.set("v.isLoading", false);

                        alert('Error saving data: ' + data.message);
                    }
                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout');
                } else if (state === "ERROR") {
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
        } else {
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        }
    }
})