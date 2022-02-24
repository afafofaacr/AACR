/**
 * Created by afaf.awad on 2/26/2021.
 */

({
    getRowActions: function (cmp, row, doneCallback) {
        var actions = [];

        if (row.Status__c == 'Incomplete') {
            actions.push({
                'label': 'Continue',
                'name': 'continue'
            });
            // deleteAction.disabled = 'true';
        }
        if (row.Status__c == 'Rejected') {
            actions.push({
                'label': 'Resubmit',
                'name': 'resubmit'
            });
            // deleteAction.disabled = 'true';
        }
        actions.push({
            'label': 'Delete',
            'name': 'delete'
        });
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },

    deleteRow : function(cmp, orderId){
        var action = cmp.get("c.deleteRecord");
        action.setParams({
            'orderId': orderId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var orders = response.getReturnValue();
                if(orders){
                    orders.forEach(function (row) {
                        row.Requested_By = row.Requested_By__r.FirstName + ' ' + row.Requested_By__r.LastName;
                        row.link = '/apex/EC_OrderReview?c__orderId=' + row.Id + '&c__status=' + row.Status__c;
                        // console.log('Order Data = ' + JSON.stringify(orders));
                    });

                    cmp.set('v.orders', orders);
                }

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

    continueOrder : function(cmp,orderId){
        var action = cmp.get("c.getIncompleteOrder");
        action.setParams({
            'orderId' : orderId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var redirectURL = response.getReturnValue();
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

    convertMiliseconds: function (cmp, miliseconds) {
        var days, hours, minutes, seconds, total_hours, total_minutes, total_seconds;

        total_seconds = parseInt(Math.floor(miliseconds / 1000));
        total_minutes = parseInt(Math.floor(total_seconds / 60));
        total_hours = parseInt(Math.floor(total_minutes / 60));
        // days = parseInt(Math.floor(total_hours / 24));
        // seconds = parseInt(total_seconds % 60);
        minutes = parseInt(total_minutes % 60);
        hours = parseInt(total_hours % 24);

        minutes = minutes < 10 ? '0' + minutes : minutes;
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours > 12 ? hours - 12 : hours;
        // hours = hours < 10 ? '0' + hours : hours;

        return hours + ':' + minutes + ampm;
    },

    buildEmailActivity : function(cmp, orderIds){
        cmp.set('v.loadingEmailActivity', true);
        console.log('getting email activity...');
        cmp.set('v.emailColumns', [
            {label: 'Order Num.', fieldName: 'orderNum', type: 'text'},
            {label: 'Total Emails Open', fieldName: 'opens', type: 'text'},
            {label: 'Total Clicks', fieldName: 'clicks', type: 'text'}
        ]);

        console.log('orderIds = ' + JSON.stringify(orderIds));
        var action = cmp.get("c.getEmailActivityList");
        action.setParams({
            jsonString : JSON.stringify(orderIds)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('returned Data = ' + JSON.stringify(data));

                if(JSON.stringify(data != '[]')) {
                    cmp.set('v.emailActivity', data);
                }
                cmp.set('v.loadingEmailActivity', false);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
                cmp.set('v.loadingEmailActivity', false);
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
                cmp.set('v.loadingEmailActivity', false);
            }
        });
        $A.enqueueAction(action);
    }

});