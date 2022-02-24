/**
 * Created by lauren.lezberg on 2/28/2019.
 */
({

    doInit : function(cmp, event, helper){
        console.log('JP_FileUpload init...');


        if(cmp.get("v.fileId")!=null){
            var action = cmp.get("c.getFileName");
            action.setParams({
                "fileId": cmp.get("v.fileId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    cmp.set("v.fileName", data);
                } else if (state === "INCOMPLETE") {
                    console.log('Could not delete file: Incomplete Callout');
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
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
        }
    },

    // testUploadFinished: function (cmp, event) {
    //     console.log('JP_EducationInfo init...');
    //
    //     // Get the list of uploaded files
    //     console.log('testUploadFinished...');
    //     var uploadedFiles = event.getParam("files");
    //     alert("Files uploaded : " + uploadedFiles.length);
    // },

    handleUploadFinished: function (cmp, event, helper) {
        console.log('JP_FileUpload handleUploadFinished...');
        console.log("contentDocumentId: " + cmp.get("v.contentDocumentId"));
        cmp.set("v.uploading", true);
        cmp.set("v.errorMsg", '');

        var fileTypes = cmp.get("v.acceptedFileTypes");
        var file = event.getSource().get("v.files")[0];

        //check the file is of a valid type
        if(fileTypes.includes(file.type) && file.type!=null && file.type != '') {
            var fileName = file.name;
            if(cmp.get("v.fileNameOverride")!=null){
                var fileNameOverride = cmp.get("v.fileNameOverride");
                var uploadedName = file.name;
                var idx = uploadedName.lastIndexOf('.');
                fileName = fileNameOverride +  uploadedName.substring(idx, uploadedName.length);
            }

            cmp.set("v.fileName", fileName);

            //uploading file
            helper.uploadHelper(cmp, event, file);

            $A.util.removeClass(cmp.find('fileInput'), 'customError');
        } else {
            cmp.set("v.uploading", false);
            cmp.set("v.errorMsg", 'This file type is not accepted. Please try another file.');
        }
    },

    removeFileAttachment : function(cmp, event, helper){
        console.log('JP_FileUpload removeFileAttachment...');

        helper.deleteFile(cmp, cmp.get("v.fileName"));

    }
})