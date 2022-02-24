/**
 * Created by lauren.lezberg on 8/30/2021.
 */

({
    setCheckboxInfo : function(cmp, event){
        var isChecked = cmp.find('checkbox').get("v.value");
        console.log('isChecked: ' + isChecked);
        if(isChecked){
            cmp.set("v.showFileUpload", true);
            var action = cmp.get("c.getPrePostDocCertification");
            action.setParams({
                "contactId": cmp.get("v.contactId")
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    if(resp!=null) {
                        cmp.find('fileUpload').set("v.fileId", resp.Id);
                        cmp.find('fileUpload').set("v.fileName", resp.Title);
                        cmp.find('fileUpload').set("v.contentDocumentId", resp.ContentDocumentId);
                        cmp.find('fileUpload').set("v.uploadDate", resp.LastModifiedDate);
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
        } else {
            cmp.set("v.showFileUpload", false);
        }
    }
});