/**
 * Created by lauren.lezberg on 2/11/2021.
 */

({

    doInit : function(cmp, event, helper){
        cmp.set("v.isLoading", true);
        var salesOrderId = helper.getSalesOrderId(cmp);
        cmp.set("v.salesOrderId", salesOrderId);
        var eventId = helper.getChildEventId(cmp);
        cmp.set("v.eventId", eventId);

        var action = cmp.get("c.getCFRegInfo");
        action.setParams({
            "careerFairEventId": eventId,
            "salesOrderId" : salesOrderId
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set('v.isLoading', false);
                console.log('data: ' + JSON.stringify(data));
                cmp.set("v.contactId", data.contactId);
                cmp.find('resume').set("v.fileId", data.fileId);
                if(data.registered){
                    cmp.find('register').set("v.checked", true);
                    $A.util.removeClass(cmp.find('resumePanel'), 'slds-hide');
                }

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:doInit');
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


    onStepChange : function(cmp, event, helper){
        console.log('onStepChange...');
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");
        // cmp.set('v.isLoading', true);


        if(cmp.find('register').get("v.checked")==true) {
            if (cmp.find('resume').get("v.fileId") != null) {
                cmp.set("v.isLoading", true);
                helper.createParticipant(cmp, stepId, cmpName);
            } else {
                // cmp.set('v.isLoading', false);
                cmp.find('resume').set("v.errorMsg", 'You must upload a resume.');
            }
        } else {
            cmp.set("v.isLoading", true);
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        }

    },

    handleCheckboxChange : function(cmp, event, helper){
        var register = cmp.find('register').get("v.checked");
        console.log(register);
        if(register){
            $A.util.removeClass(cmp.find('resumePanel'), 'slds-hide');
        } else {
            $A.util.addClass(cmp.find('resumePanel'), 'slds-hide');
            helper.removeCareerFairSOLine(cmp);
        }

    },

    handleUploadFinished : function(cmp, event, helper){
        console.log('handleUploadFinished..');
        var uploadedFiles = event.getParam("files");
        cmp.set("v.fileId", uploadedFiles[0].documentId);

        // var imgName = uploadedFiles[0].name.substring(0, uploadedFiles[0].name.lastIndexOf('.'));
        // cmp.find("mainImg").set("v.value", imgName);
    }
});