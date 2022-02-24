/**
 * Created by afaf.awad on 2/8/2021.
 */

({
    doInit: function(cmp,event,helper){
        console.log('DoInit...');
        var actions = helper.getRowActions.bind(this, cmp);
        cmp.set('v.orderColumns', [
            {label: 'Order Num.', fieldName: 'link', type: 'url',
                typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Order Name', fieldName: 'Order_Name__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'},
            {label: 'Date', fieldName: 'Order_Date__c', type: 'text'},
            {label: 'Requester', fieldName: 'Requested_By', type: 'text'},
            { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
        ]);

        cmp.set('v.scheduleColumns', [
            {label: 'Order Num.', fieldName: 'OrderNum', type: 'text'},
            {label: 'Schedule', fieldName: 'deliveryDate', type: 'text'},
            {label: 'Count', fieldName: 'OrderCount', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'},
        // { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
        ]);
        var action = cmp.get("c.getDashboardInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('returned Data = ' + JSON.stringify(data));
                var orders = data.orders;
                if(data.orders.length !== 0) {
                    orders.forEach(function (row) {
                        row.Requested_By = row.Requested_By__r.FirstName + ' ' + row.Requested_By__r.LastName;
                        row.link = '/apex/EC_OrderReview?c__orderId=' + row.Id + '&c__status=' + row.Status__c;
                        // console.log('Order Data = ' + JSON.stringify(orders));
                    });
                }

                var schedule = orders.length == 0 ? [] : data.timeSlots;
                    if (schedule.length !== 0) {
                        var orderIds = [];
                        schedule.forEach(function (row) {
                            row.OrderNum = row.EC_Order__r.Name;
                            row.OrderCount = row.EC_Order__r.Amount_Targeted__c;
                            row.deliveryDate = row.Delivery_Date__c + '  ' + helper.convertMiliseconds(cmp, row.Start_Time__c);
                            orderIds.push(row.EC_Order__c);

                        });
                        // helper.buildEmailActivity(cmp, orderIds);
                    }

                cmp.set('v.orders', orders);
                cmp.set('v.schedule', schedule);

                if(data.exSetting) {
                    if (data.exSetting.Verified_Domain__c == null) {
                        cmp.set('v.disableOrderBtn', true);
                    }
                }else{
                    cmp.set('v.disableOrderBtn', true);
                }
                cmp.set('v.isLoading', false);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
                cmp.set('v.isLoading', false);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
                cmp.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);

    },

    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'continue':
                helper.continueOrder(cmp,row.Id);
                break;
            case 'resubmit':
                helper.continueOrder(cmp,row.Id);
                break;
            case 'delete':
                helper.deleteRow(cmp,row.Id);
                break;
        }

    },

    startNewOrder : function(cmp,event,helper){
        console.log('Calling new order process...');
        var action = cmp.get("c.getExhibitorOrderProcessId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var redirectURL = response.getReturnValue();
                console.log('redirectURL: ' + redirectURL);
                window.location.href = redirectURL;
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    },

    goToSettings : function(cmp,event,helper){
        var action = cmp.get("c.getExhbitorSettingURL");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var redirectURL = response.getReturnValue();
                console.log('redirectURL: ' + redirectURL);
                window.location.href = redirectURL;
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    }
});