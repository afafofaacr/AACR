/**
 * Created by afaf.awad on 3/1/2021.
 */

({
    doInit: function(cmp, event, helper){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getAvailableYears");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var currentYear = new Date().getFullYear();
                var years = [];
                data.forEach(function(d){
                    years.push({label:d, value: d});
                });
                cmp.set("v.yvalue", currentYear);
                cmp.set("v.years", years);

                var month = new Date().getMonth() + 1;
                cmp.set("v.mvalue",month.toString());
                helper.getEventsByMonth(cmp);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("getEventsByMonth Error - message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("getEventsByMonth Unknown error");
                }
                cmp.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    changeYear : function(cmp, event, helper){
        cmp.set("v.isLoading", true);
        var newYear = event.getSource().get("v.value");
        cmp.set("v.yvalue", newYear);
        helper.getEventsByMonth(cmp);
    },

    goToNew : function(cmp, event, helper){
        cmp.set("v.openNew", true);
    },

    changeMonth : function(cmp, event, helper){
        console.log('month changing...');
        cmp.set("v.isLoading", true);
        helper.getEventsByMonth(cmp);
    }


    // doInit: function(cmp,event,helper){
    // var actions = helper.getRowActions.bind(this, cmp);
    // cmp.set('v.orderColumns', [
    //     {label: 'Order Num.', fieldName: 'Name', type: 'text'},
    //     {label: 'Company', fieldName: 'Order_Name__c', type: 'text'},
    //     {label: 'Submitted', fieldName: 'Status__c', type: 'text'},
    //     {label: 'Submitted By', fieldName: 'Requested_By', type: 'text'},
    //     { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
    // ]);
    //
    // cmp.set('v.scheduleColumns', [
    //     {label: 'Order Num.', fieldName: 'OrderNum', type: 'text'},
    //     {label: 'Company', fieldName: 'Delivery_Date__c', type: 'date'},
    //     {label: 'Approved', fieldName: 'OrderCount', type: 'text'},
    //     {label: 'Approved By', fieldName: 'Status__c', type: 'text'},
    //     // { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
    // ]);
    //     var action = cmp.get("c.getDashboardInfo");
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var data = response.getReturnValue();
    //             console.log('returned Data = ' + JSON.stringify(data));
    //             if(data.exSetting == null){
    //                 cmp.set('v.schedule', data);
    //             }
    //             if(JSON.stringify(data.orders != '[]')) {
    //                 var orders = data.orders;
    //                 orders.forEach(function (row) {
    //                     row.Requested_By = row.Requested_By__r.FirstName + ' ' + row.Requested_By__r.LastName;
    //                     // console.log('Order Data = ' + JSON.stringify(orders));
    //                 });
    //             }
    //             if(JSON.stringify(data.timeSlots != '[]')) {
    //                 var schedule = data.timeSlots;
    //                 schedule.forEach(function (row) {
    //                     row.OrderNum = row.EC_Order__r.Name;
    //                     row.OrderCount = row.EC_Order__r.Amount_Targeted__c;
    //                 });
    //                 // console.log('Schedule Data = ' + JSON.stringify(schedule));
    //
    //
    //                 cmp.set('v.orders', orders);
    //                 cmp.set('v.schedule', schedule);
    //             }
    //
    //         } else if (state === "INCOMPLETE") {
    //             console.log('Incomplete Callout: - doInit');
    //         } else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message - doInit: " +
    //                         errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error: doInit");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    //
    // },

    // handleRowAction: function (cmp, event, helper) {
    //     var action = event.getParam('action');
    //     var row = event.getParam('row');
    //     switch (action.name) {
    //         case 'continue':
    //             helper.continueOrder(cmp,row.Id);
    //             break;
    //         case 'delete':
    //             console.log('row = ' + JSON.stringify(row));
    //             helper.deleteRow(cmp,row.Id);
    //             break;
    //     }
    //
    // },
    //
    // goToApproveOrder: function (cmp, event, helper) {
    //     cmp.set("v.processing", true);
    //     var action = cmp.get("c.getOrderForApproval");
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var jpId = response.getReturnValue();
    //             console.log('jpId: ' + jpId);
    //
    //             var pageReference = {
    //                 type: 'standard__component',
    //                 attributes: {
    //                     componentName: 'c__BAMContainer',
    //                 },
    //                 state: {
    //                     "c__id": jpId,
    //                     "c_orderId" : cmp.get("v.recordId")
    //                 }
    //             };
    //
    //             cmp.set("v.processing", false);
    //             // cmp.set("v.pageReference", pageReference);
    //             var navService = cmp.find("navService");
    //             navService.navigate(pageReference);
    //
    //         } else if (state === "INCOMPLETE") {
    //             // do something
    //             cmp.set("v.processing", false);
    //
    //         } else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " +
    //                         errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //             cmp.set("v.processing", false);
    //         }
    //     });
    //     $A.enqueueAction(action);
    // }
});