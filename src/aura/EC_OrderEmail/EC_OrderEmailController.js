/**
 * Created by afaf.awad on 2/15/2021.
 */

({
    doInit : function(cmp,event, helper) {
        // console.log('getting email info...');
        console.log('stepId = ' + cmp.get('v.stepId'));
        cmp.set('v.isLoading',true);
        var action = cmp.get("c.getEmailRecord");
        action.setParams({
            "orderId": helper.getOrderId(cmp),
            "stepId" : cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                if(data) {
                    cmp.set('v.emailId', data.Id);
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

    updatePreview : function(cmp, event, helper){
        helper.hideMessage(cmp);
        cmp.set('v.processUpdate', true);
        cmp.set('v.updatePreview', true);
        if(helper.validate(cmp)) {
            // cmp.find('bodyField').set("v.value", cmp.find("bodyInput").get("v.value"));
            cmp.find('emailForm').submit();
            cmp.find("emailPreview").refreshPreview();
        }
        cmp.set('v.processUpdate', false);
    },

    handleSave : function(cmp,event,helper){
        helper.hideMessage(cmp);
        // console.log('saving...');
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        if(helper.validate(cmp)) {

            console.log('validate is true');
            cmp.set("v.isLoading", true);
            // cmp.find('bodyField').set("v.value", cmp.find("bodyInput").get("v.value"));
            cmp.find('emailForm').submit();
        }
    },

    handleOnLoad : function(cmp,event,helper){
        // var emailBody = cmp.find("bodyField").get("v.value");
        // cmp.find('bodyInput').set("v.value", emailBody);
        //
        cmp.find("emailPreview").refreshPreview();
        cmp.set('v.isLoading',false);

    },

    handleSuccess: function (cmp, event, helper) {
        console.log('handleSuccess...');

        if(cmp.get('v.updatePreview')){
            cmp.set('v.updatePreview',false);
        }else {
            cmp.set("v.isLoading", true);
            var stepId = cmp.get("v.nextStepId");
            var cmpName = cmp.get("v.nextCmpName");

            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        }
    },

    handleError: function (cmp, event, helper) {
        cmp.set("v.isLoading", false);
        var errors = event.getParams();
        console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.nextStepId");
        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

    handleTestEmail: function (cmp,event,helper){
        //Validate test email input
        helper.hideMessage(cmp);
        var testEmail = cmp.find('emailTest');
        var testEmailVal = testEmail.get("v.value");
        if (!testEmailVal) {
            $A.util.addClass(testEmail, 'slds-has-error');
            cmp.find('errorMsg').setError('Enter a valid email address to send a test.');
        } else {
            $A.util.removeClass(testEmail, 'slds-has-error');
            cmp.find('errorMsg').setError('');
        }

        //Save record first
        cmp.set('v.processSend', true);
        cmp.set('v.updatePreview', true); //to prevent handleSuccess function from going to next page.
        if(helper.validate(cmp)) {
            cmp.find('emailForm').submit();
            // Send test email
            var action = cmp.get("c.sendTestEmail");
            action.setParams({
                "testEmail": testEmailVal,
                "emailId": cmp.get('v.emailId')
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    console.log('data: ' + data);
                    if (data) {
                        cmp.set('v.processSend', false);
                        $A.util.removeClass(cmp.find('toastMsg'), 'slds-hide');
                        $A.util.addClass(cmp.find('toastMsg'), 'slds-show');
                    }
                } else if (state === "INCOMPLETE") {
                    cmp.set('v.processSend', false);
                    console.log("Error: Incomplete callout.");
                } else if (state === "ERROR") {
                    cmp.set('v.processSend', false);
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
        }else{
            cmp.set('v.processSend', false);
        }
    },

    closeMessage : function(cmp, event, helper){
        helper.hideMessage(cmp);
    },

});