/**
 * Created by afaf.awad on 12/12/2019.
 */

({
    validated : function (cmp, event, fieldId, valid) {

        const stepId = event.getParam("stepId");
        const cmpName = event.getParam("cmpName");

        if(valid) {
            let valEvt = $A.get("e.c:ValidateEvt");
            valEvt.setParams({"isValid": valid});
            valEvt.setParams({"fieldId": fieldId});
            valEvt.setParams({"stepId": stepId});
            valEvt.setParams({"cmpName": cmpName});
            valEvt.fire();
        }
    },

    deleteFile: function(cmp, fileName) {
        let action = cmp.get("c.removeFile");
        action.setParams({
            "fileName": fileName.Name,
            "recordId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.fileObj", null);
            } else if (state === "INCOMPLETE") {
                console.log('Could not delete file: Incomplete Callout');
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not delete file: Error message - " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not delete file: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    getAttachment: function (cmp, documentId){

        let action = cmp.get("c.getAttachments");
        action.setParams({
            "documentId": documentId,
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let fileObj = response.getReturnValue();
                cmp.set("v.fileObj", fileObj);
                cmp.set("v.fileName", fileObj.Title);
                console.log('fileObj = ' + JSON.stringify(fileObj));
            } else if (state === "INCOMPLETE") {
                console.log('Could not retrieve file, INCOMPLETE');
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could retrieve file: Error message - " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could retrieve file: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    }

});