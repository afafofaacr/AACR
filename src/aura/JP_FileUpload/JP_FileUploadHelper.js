/**
 * Created by lauren.lezberg on 3/13/2019.
 */
({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
    // MAX_FILE_SIZE: 2000000000, //max file size is 2GB
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb

    uploadHelper : function(cmp, event, file){
        console.log('JP_FileUpload uploadHelper...');


        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function
        if (file.size > self.MAX_FILE_SIZE) {
            cmp.set("v.errorMsg", 'Error : File size cannot exceed ' + self.MAX_FILE_SIZE/1000000 + ' MB.\n' + ' Selected file size: ' + file.size/1000000 + ' MB');
            return;
        }

        // create a FileReader object
        var objFileReader = new FileReader();
        // set onload function of FileReader object
        objFileReader.onload = $A.getCallback(function() {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;

            fileContents = fileContents.substring(dataStart);
            // call the uploadProcess method
            self.uploadProcess(cmp, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        console.log('JP_FileUpload uploadInChunk...');
        console.log("attachId: " + attachId);
        console.log('file type: ' + file.type);
        console.log("startPosition: " + startPosition);
        console.log("endPosition: " + endPosition);

        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);

        var action = component.get("c.saveChunk");
        var fileName = component.get("v.fileName");

        action.setParams({
            parentId: component.get("v.recordId"),
            fileName: fileName,
            base64Data: encodeURIComponent(getchunk),
            fileId: attachId,
            fCategory : component.get("v.fileCategory"),
            contentDocumentId : component.get("v.contentDocumentId")
        });

        // set call back
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // store the response / Attachment Id
                var contentVersion = response.getReturnValue();
                console.log('contentVersion: ' + JSON.stringify(contentVersion));
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion
                // then call again 'uploadInChunk' method ,
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    console.log('start position still less than end position');
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, contentVersion.Id);
                } else {
                    console.log('contentVersion: ' + JSON.stringify(contentVersion));
                    component.set("v.fileId", contentVersion.Id);
                    component.set("v.contentDocumentId", contentVersion.ContentDocumentId);
                    component.set("v.uploadDate", new Date());
                    component.set("v.uploading", false);
                }
                // handle the response errors
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // enqueue the action
        $A.enqueueAction(action);
    },


    uploadProcess: function(component, file, fileContents) {
        console.log('JP_FileUpload uploadProcess...');

        // set a default size or startpostiton as 0
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
       this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');

    },


    deleteFile: function(cmp, fileName) {
        console.log('JP_FileUpload deleteFile...');

        var action = cmp.get("c.removeFile");
        action.setParams({
            "fileId": cmp.get("v.fileId"),
            "recordId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data) {
                    cmp.set("v.FileList", []);
                    if (cmp.get("v.fileNameOverride") != null) {
                        cmp.set("v.fileName", cmp.get("v.fileNameOverride"));
                    } else {
                        cmp.set("v.fileName", null);
                    }
                    cmp.set("v.fileId", null);
                    cmp.set("v.contentDocumentId", null);
                }
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
    },
})