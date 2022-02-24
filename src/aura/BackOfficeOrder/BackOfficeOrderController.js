/**
 * Created by lauren.lezberg on 8/23/2019.
 */
({
    doInit: function (cmp, event, helper) {
        console.log('BackOfficeOrder init...');

        cmp.set("v.salesOrderId", helper.getSalesOrderId(cmp));
        var isRenew = helper.getIsRenew(cmp);
        cmp.set("v.isRenewal", isRenew);

        window.setTimeout(
            $A.getCallback(function () {
                var action = cmp.get("c.getBackOfficeData");
                action.setParams({
                    "salesOrderId": helper.getSalesOrderId(cmp),
                    "isRenew": isRenew
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var data = response.getReturnValue();
                        //set sales order lines
                        cmp.set("v.renewalsOpen", data.renewalsOpen);
                        cmp.set("v.salesOrderLines", data.lines);

                        //find line with membership & set sub plan
                        var managedMembership = false;
                        data.lines.forEach(function (line) {
                            if (line.OrderApi__Item_Class__r.Name == 'Individual Memberships' &&
                                !line.OrderApi__Item__r.Name.includes('Emeritus') &&
                                !line.OrderApi__Item__r.Name.includes('Honorary')) {
                                //set subPlanId for memberships except honorary and lifetime
                                cmp.set("v.subPlanId", line.OrderApi__Subscription_Plan__c);
                                if (line.OrderApi__Item__r.Managed__c) {
                                    managedMembership = true;
                                }
                            }
                        });

                        //set term options if there's a managed membership
                        if (managedMembership) {
                            var termOptions = [];
                            var selectedTerm = null;
                            // console.log('subPlans: ' + data.subscriptionPlans);
                            /**Create term options from available subscription plans**/
                            data.subscriptionPlans.forEach(function (term) {
                                // console.log('term: ' + JSON.stringify(term));
                                data.lines.forEach(function (line) {
                                    /**if there's a membership item**/
                                    if (line.OrderApi__Item_Class__r.Name == 'Individual Memberships' && !line.OrderApi__Item__r.Name.includes('Emeritus') && !line.OrderApi__Item__r.Name.includes('Honorary')) {
                                        /** set selected term from membership sub plan & activation date **/
                                        if (line.OrderApi__Subscription_Plan__c == term.subPlanId && term.termYear.includes(new Date(line.OrderApi__Activation_Date__c).getUTCFullYear())) {
                                            selectedTerm = term.termYear;
                                        }
                                    }
                                });
                                var option = {};
                                option.label = term.termYear;
                                option.value = term.termYear;
                                option.id = term.subPlanId;
                                termOptions.push(option);
                            });

                            if (selectedTerm != null) {
                                cmp.set("v.termValue", selectedTerm);
                            }

                            cmp.set("v.termOptions", termOptions);
                        }
                        cmp.set("v.isLoading", false);
                    } else if (state === "INCOMPLETE") {
                        console.log('Could not retrieve data: Incomplete Callout');
                        cmp.set("v.processing", false);
                        cmp.set("v.isLoading", false);
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
                        cmp.set("v.isLoading", false);
                    }

                });
                $A.enqueueAction(action);
            }), 4000
        );
    },

    handleSubPlanChange: function (cmp, event, helper) {
        console.log('BackOfficeOrder handleSubPlanChange...');
        var oldPlanId = event.getParam("oldValue");
        var newPlanId = cmp.get('v.subPlanId');
        if(oldPlanId != newPlanId){
            helper.getTermOpts(cmp);
        }

        if(oldPlanId!=null && newPlanId==null){
            cmp.set("v.termOptions", []);
            cmp.set("v.termValue", null);
        }
    },

    /**
     * @purpose Find correct subscription plan id based on selected term value, call controller to update subscription plan for all sales order lines
     * Method will only be used when renewals are open and order is not a renewal
     * @param cmp
     * @param event
     * @param helper
     */
    termChange: function (cmp, event, helper) {
        console.log('BackOfficeOrder termChange...');

        cmp.set("v.processing", true);
        cmp.set("v.errorMsg", null);
        cmp.set("v.selectedId", null);

        var termOpts = cmp.get("v.termOptions");

        var orderEntry = cmp.find('orderEntry');
        [].concat(orderEntry)[0].clear();

        var subPlanId = null;
        var futureEndDate = false;
        var termValue = cmp.get("v.termValue");
        if (termValue != null) {
            if (termValue > new Date().getFullYear().toString()) {
                futureEndDate = true;
            }
            termOpts.forEach(function (term) {
                if (term.value == termValue) {
                    subPlanId = term.id;
                }
            });
        }

        var action = cmp.get("c.changeTerm");
        action.setParams({
            "subPlanId": subPlanId,
            "futureEndDate": futureEndDate,
            "salesOrderId": cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data);
                cmp.set("v.processing", false);
                cmp.set("v.subPlanId", subPlanId);

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

    /**
     * @purpose Performs validation check to make sure membership items contain Blood Cancer Discovery Journal, if an active membership is present the COMP journal is added and the term is selected
     * All sales order lines are saved and upon success, the user is redirected to next step in process, otherwise, user receives and error message and stays on the same page
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave: function (cmp, event, helper) {
        console.log('BackOfficeOrder handleSave...');

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if (!cmp.get("v.processing")) {
            cmp.set("v.processing", true);

            var termValue = cmp.get("v.termValue");
            var isRenew = cmp.get("v.isRenewal");

            var isActive = false;
            var hasCompJournal = false;
            var hasBloodCancerJournal = false;
            var salesOrderLines = cmp.get("v.salesOrderLines");
            salesOrderLines.forEach(function (line) {
                if (line.OrderApi__Item__r.Name.includes('Blood Cancer Discovery')) {
                    hasBloodCancerJournal = true;
                }
                if (line.OrderApi__Item__r.Name == 'Active Membership') {
                    isActive = true;
                }
                if (line.OrderApi__Item__r.Name.includes('COMP') || line.OrderApi__Item__r.Name == 'Declined Free Journal') {
                    hasCompJournal = true;
                }
            });

            if ((isActive && !hasCompJournal) || !hasBloodCancerJournal) {
                if (isActive && !hasCompJournal) {
                    cmp.set("v.errorMsg", 'Active memberships require a COMP or decline journal item. In order to continue, please add one of these items or select another membership type.');
                } else if (!hasBloodCancerJournal) {
                    cmp.set("v.errorMsg", 'You must add the Blood Cancer Discovery journal to the order before continuing.');
                }

                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": cmp.get("v.stepId")});
                navEvt.setParams({"cmpName": null});
                navEvt.fire();
            } else {
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": stepId});
                navEvt.setParams({"cmpName": cmpName});
                navEvt.fire();
            }
        }
    },


})