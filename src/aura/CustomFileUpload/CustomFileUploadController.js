/**
 * Created by lauren.lezberg on 11/12/2019.
 */
({
    testUploadFinished: function (cmp, event) {
        // Get the list of uploaded files
        console.log('testUPloadFInished...');
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
    },

    uploadFile : function(cmp, event, helper){
        console.log('file uploading to record: ', cmp.get("v.recordId"));
        var files = cmp.get("v.FileList");
        if(files!=null) {
            cmp.set("v.uploading", true);
            cmp.set("v.errorMsg", '');
            
            //uploading file
            helper.uploadHelper(cmp, event, files[0]);
        }

    },

    handleUploadFinished: function (cmp, event, helper) {

        cmp.set("v.uploading", true);
        cmp.set("v.errorMsg", '');

        var fileTypes = cmp.get("v.acceptedFileTypes");
        var file = event.getSource().get("v.files")[0];
        console.log('file: ' + file.name);

        //check the file is of a valid type
        if(fileTypes.includes(file.type) && file.type!=null && file.type != '') {
            cmp.set("v.fileName", file.name);
            $A.util.removeClass(cmp.find('fileInput'), 'customError');
        } else {
            cmp.set("v.errorMsg", 'This file type is not accepted. Please try another file.');
        }
        cmp.set("v.uploading", false);
    },

    removeFileAttachment : function(cmp, event, helper){
        helper.deleteFile(cmp, cmp.get("v.fileName"));

    }
})