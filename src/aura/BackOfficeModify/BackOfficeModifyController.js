/**
 * Created by lauren.lezberg on 2/3/2020.
 */
({
    /**
     * @purpose Initializes component
     * @param cmp
     * @param event
     * @param helper
     */
    doInit : function(cmp, event, helper){
        console.log('BackOfficeModify init...');
        var salesOrderId = helper.getSalesOrderId(cmp);
        cmp.set("v.salesOrderId", salesOrderId);
        var message = 'ERROR: ';
        var action = cmp.get("c.getModifyInfo");
        action.setParams({
            "salesOrderId": salesOrderId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.subPlanId", data.subPlanId);
                cmp.set("v.salesOrderLines", data.soLines);
                cmp.set("v.contactId", data.contactId);

            } else if (state === "INCOMPLETE") {
                message += 'Could not retrieve data: Incomplete Callout';
                cmp.find("errorMsg").set("v.errorMsg", message);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message += errors[0].message;
                    }
                } else {
                    message += 'Could not retrieve data: Unknown error';
                }
                cmp.find("errorMsg").set("v.errorMsg", message);
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Remove selected item from sales order
     * @param cmp
     * @param event
     * @param helper
     */
    removeItemFromSalesOrder : function(cmp, event, helper){
        console.log('BackOfficeModify removeItemFromSalesOrder...');

        cmp.set("v.processing", true);
        var message = 'ERROR: ';

        var selectedItem = event.getSource().get("v.value");
        var action = cmp.get("c.removeSelectedItemFromSO");
        action.setParams({
            "itemId" : selectedItem,
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data);
                cmp.set("v.selectedId", null);
                cmp.set("v.processing", false);
                var itemLookup = cmp.find('itemLookup');
                [].concat(itemLookup)[0].clearAccount();
            }
            else if (state === "INCOMPLETE") {
                message += 'Could not retrieve data: Incomplete Callout';
                cmp.find("errorMsg").set("v.errorMsg", message);
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message += errors[0].message;
                    }
                } else {
                    message += 'Could not retrieve data: Unknown error';
                }
                cmp.find("errorMsg").set("v.errorMsg", message);
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Add selected item to sales order with selected term, reset item list to include new item and clear item lookup
     * @param cmp
     * @param event
     * @param helper
     */
    addItemToSalesOrder : function(cmp, event, helper){
        console.log('BackOfficeModify addItemToSalesOrder...');

        cmp.set("v.processing", true);
        var message = 'ERROR: ';

        var action = cmp.get("c.addSelectedItemToSO");
        action.setParams({
            "itemId" : cmp.get("v.selectedId"),
            "subPlanId" : cmp.get("v.subPlanId"),
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.salesOrderLines", data);
                cmp.set("v.selectedId", null);
                cmp.set("v.processing", false);
                var itemLookup = cmp.find('itemLookup');
                [].concat(itemLookup)[0].clearAccount();
            }
            else if (state === "INCOMPLETE") {
                message += 'Could not retrieve data: Incomplete Callout';
                cmp.find("errorMsg").set("v.errorMsg", message);
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message += errors[0].message;
                    }
                } else {
                    message += 'Could not retrieve data: Unknown error';
                }
                cmp.find("errorMsg").set("v.errorMsg", message);
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);
    },


    /**
     * @purpose Handles confirmation from modal to cancel subscriptions and remove membership item from sales order and fires navigate event
     * @param cmp
     * @param event
     * @param helper
     */
    handleModalConfirm : function(cmp, event, helper){
        console.log('BackOfficeModify handleModalConfirm...');

        cmp.set("v.processing", true);
        var message = 'ERROR: ';
        cmp.find('currentSubs').cancelSubs();

        var action = cmp.get("c.removeMembershipFromSO");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.processing", false);

                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": cmp.get("v.nextStepId")});
                navEvt.setParams({"cmpName": cmp.get("v.nextCmpName")});
                navEvt.fire();
            }
            else if (state === "INCOMPLETE") {
                message += 'Could not retrieve data: Incomplete Callout';
                cmp.find("errorMsg").set("v.errorMsg", message);
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        message += errors[0].message;
                    }
                } else {
                    message += 'Could not retrieve data: Unknown error';
                }
                cmp.find("errorMsg").set("v.errorMsg", message);
                cmp.set("v.processing", false);
            }

        });
        $A.enqueueAction(action);


    },

    /**
     * @purpose Handles cancel from modal popup and fires null navigate event to stay on page
     * @param cmp
     * @param event
     * @param helper
     */
    handleModalReject : function(cmp, event, helper){
        console.log('BackOfficeModify handleModalReject...');

        cmp.set("v.modalOpen", false);
        cmp.set("v.processing", false);

        //fire null event
        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": cmp.get("v.stepId")});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },


    /**
     * @purpose Performs validation and opens modal accordingly
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave : function(cmp, event, helper){
        console.log('BackOfficeModify handleSave...');

        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        //perform validation
        var isActive = false;
        var hasCOMPSub = false;
        var hasCOMPLine = false;

        var currentSubs = cmp.get("v.subscriptions");
        currentSubs.forEach(function(sub){
            if(sub.OrderApi__Item__r.Name == 'Active Membership'){
               isActive = true;
            }
            if(sub.OrderApi__Item__r.Name.includes('COMP') || sub.OrderApi__Item__r.Name == 'Declined Free Journal'){
                hasCOMPSub = true;
            }
        });

        var salesOrderLines = cmp.get("v.salesOrderLines");
        salesOrderLines.forEach(function(line){
            if(line.OrderApi__Item__r.Name.includes('COMP') || line.OrderApi__Item__r.Name == 'Declined Free Journal'){
                hasCOMPLine = true;
            }
        });

        var message='';

        //if missing comp
        if((isActive && !hasCOMPSub && !hasCOMPLine)){
            message += 'Active memberships require a COMP or decline journal item. In order to continue, please add one of these items or select another membership type.';
            cmp.find("errorMsg").set("v.errorMsg", message);

            //fire null event
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();

        } else if (hasCOMPSub && hasCOMPLine){ //if two comps
            message += 'You cannot have two COMP journals. In order to continue, please remove a COMP journal from either the existing subscriptions or newly added items.';
            cmp.find("errorMsg").set("v.errorMsg", message);

            //fire null event
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();

        } else{ //if IS valid
            cmp.set("v.modalOpen", true);
        }
    }

})