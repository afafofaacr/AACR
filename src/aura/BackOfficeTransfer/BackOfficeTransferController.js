/**
 * Created by lauren.lezberg on 11/15/2019.
 */
({
    /**
     * @purpose Initialize component by canceling old subscriptions and retrieving sales order lines already present in the sales order
     * @param cmp
     * @param event
     * @param helper
     */
    doInit : function(cmp ,event, helper){
        console.log('BackOfficeTransfer init...');

        var salesOrderId = helper.getSalesOrderId(cmp);
        cmp.set("v.salesOrderId", salesOrderId);
        
        var action = cmp.get("c.cancelOldSubscriptionsAndGetSOLines");
        action.setParams({
            "salesOrderId": salesOrderId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data.soLines);
                cmp.set("v.termValue", data.subPlanId);
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
    },

    /**
     * @purpose Performs validation check to make sure a Blood Cancer Journal is present in the sales order and if an active membership is present, a comp or decline is also present.
     * All sales order lines are saved and upon success, the user is redirected to next step in process, otherwise, user receives and error message and stays on the same page
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave: function (cmp, event, helper) {
        console.log('BackOfficeTransfer handleSave...');

        /** Get stepId and cmpName from JP_StepChangeEvt **/
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        /** Perform validation **/
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

        if ((isActive && !hasCompJournal) || !hasBloodCancerJournal || cmp.get("v.processing")){
            if (isActive && !hasCompJournal) {
                cmp.set("v.errorMsg", 'Active memberships require a COMP or decline journal item. In order to continue, please add one of these items or select another membership type.');
            } else if (!hasBloodCancerJournal) {
                cmp.set("v.errorMsg", 'You must add the Blood Cancer Discovery journal to the order before continuing.');
            }

            /** Error: Fire null JP_NavigateEvt **/
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        } else {
            /** Fire JP_NavigateEvt to move forward or backwards **/
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        }

    },

})