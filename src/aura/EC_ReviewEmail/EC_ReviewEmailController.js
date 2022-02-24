/**
 * Created by afaf.awad on 3/1/2021.
 */

({
    doInit : function(cmp,event, helper) {
        console.log('getting email info for order ' + helper.getOrderId(cmp));
        cmp.set('v.isLoading',true);
        var action = cmp.get("c.getEmailReview");
        action.setParams({
            "orderId": helper.getOrderId(cmp),
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));
                if(data) {
                    var options=[];
                    var users = data.users;
                    users.forEach(function (row){
                       options.push({ label: row.Name, value: row.Id })
                    });

                    cmp.set('v.emailId', data.email.Id);
                    cmp.find("emailPreview").refreshPreview();
                    cmp.set('v.options', options);
                    cmp.set('v.isLoading',false);
                }
            } else if (state === "INCOMPLETE") {
                console.log("Error: Incomplete callout.");
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
    },

    handleChange: function (cmp, event) {
        cmp.set('v.selectedUsers', event.getParam("value"));
        // console.log('values selected = ' +  event.getParam("value"));
    },

    sendEmail: function (cmp,event,helper){
        console.log('sending test email...');
        console.log('emailId = ' + cmp.get('v.emailId'));
        console.log('selected users = ' + JSON.stringify(cmp.get('v.selectedUsers')));
        var action = cmp.get("c.sendTestEmail");

        action.setParams({
            "emailId" : cmp.get('v.emailId'),
            "usersJson" : JSON.stringify(cmp.get('v.selectedUsers'))
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + data);
                if(data) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: "success",
                        title: 'Success!',
                        message: 'Your test emails sent successfully.',
                        duration: ' 3000',
                    });
                    toastEvent.fire();
                }
            } else if (state === "INCOMPLETE") {
                console.log("Error: Incomplete callout.");
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
    },

    handleSave: function (cmp, event, helper) {
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");
        var navEvt = $A.get("e.c:JP_NavigateEvt");

        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();
    },

    // handleError: function (cmp, event, helper) {
    //     console.log("handle error...");
    //     cmp.set("v.isLoading", false);
    //
    //     console.log(event);
    //     var errors = event.getParams();
    //     console.log("Error Response", JSON.stringify(errors));
    //
    //     var stepId = cmp.get("v.nextStepId");
    //
    //     var navEvt = $A.get("e.c:JP_NavigateEvt");
    //     navEvt.setParams({"stepId": stepId});
    //     navEvt.setParams({"cmpName": null});
    //     navEvt.fire();
    // },

});