/**
 * Created by lauren.lezberg on 2/17/2020.
 */
({

    doInit : function(cmp, event, helper){
        var eventId = helper.getEventId(cmp);
        cmp.set("v.eventId", eventId);

        cmp.find("emailPreview").refreshPreview();
    },

    handleOnLoad: function(cmp, event, helper){
        var recUi = event.getParam("recordUi");


        for(var idx = 1; idx <= 6; idx++){
            var sig = recUi.record.fields["Signature_" + idx + "__c"].value;
            if(sig!=null && sig!=undefined){
                var sigarray = sig.split('<br/>');
                cmp.find("sig" + idx).set("v.value", sigarray[0]);
                cmp.find("sig" + idx + 'Title').set("v.value", sigarray[1]);
            }
        }

    },

    handleUploadFinished : function(cmp, event, helper){
        var uploadedFiles = event.getParam("files");
        cmp.set("v.fileName", uploadedFiles[0].name);

        var action = cmp.get("c.uploadDocImage");
        action.setParams({
            "fileId": uploadedFiles[0].documentId,
            "eventId": cmp.get("v.eventId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // var data = response.getReturnValue();
                // cmp.set("v.templateBody", data);
            } else if (state === "INCOMPLETE") {
                // do something
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
        var eventId = helper.getEventId(cmp);
        helper.updateEmailTemplate(cmp, eventId, null, null);
    },

    handleSave : function(cmp, event, helper){
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        var eventId = helper.getEventId(cmp);

        cmp.find('eventEdit').submit();

        helper.updateEmailTemplate(cmp, eventId, stepId, cmpName);

    }
})