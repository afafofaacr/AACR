/**
 * Created by lauren.lezberg on 9/3/2019.
 */
({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb


    saveLogRecord : function(cmp, event){
        console.log('saving log record...');
        var logRecord = cmp.get("v.simpleNewLog");
        console.log('logRecord: ' + JSON.stringify(logRecord));

        var action = cmp.get("c.saveNewErrorLog");
        action.setParams({
            "newLogString" : JSON.stringify(logRecord)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // cmp.set("v.requestSent", true);
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('saveLogRecordData: ' + data);

                var contactId;
                if(cmp.get("v.contact")!=null && cmp.get("v.contact")!=undefined){
                    contactId = cmp.get("v.contact").Id;
                } else {
                    contactId = null;
                }

                var file = cmp.get("v.fileAttach");
                console.log('file: ' + JSON.stringify(file));
                if(file!=null) {
                    this.uploadHelper(cmp, event, file, data, contactId);
                } else {
                    this.sendAndUpload(cmp, contactId, data);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                cmp.set("v.processing", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve data: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);


        // cmp.find("LogRecordCreator").saveRecord(function(saveResult) {
        //     if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
        //         console.log('success creating record...');
        //         var newLogId = saveResult.recordId;
        //         // handle the successful create
        //         var contactId;
        //         if(cmp.get("v.contact")!=null && cmp.get("v.contact")!=undefined){
        //             contactId = cmp.get("v.contact").Id;
        //         } else {
        //             contactId = null;
        //         }
        //
        //         var file = cmp.get("v.FileList");
        //         console.log('file: ' + file);
        //         if(file!=null) {
        //             this.uploadHelper(cmp, event, file[0], newLogId, contactId);
        //         } else {
        //             cmp.set("v.requestSent", true);
        //             this.sendAndUpload(cmp, contactId, newLogId);
        //         }
        //     } else if (saveResult.state === "INCOMPLETE") {
        //         // handle the incomplete state
        //         console.log("User is offline, device doesn't support drafts.");
        //     } else if (saveResult.state === "ERROR") {
        //         // handle the error state
        //         console.log('Problem saving log, error: ' + JSON.stringify(saveResult.error));
        //     } else {
        //         console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
        //     }
        // });
    },

    uploadHelper : function(cmp, event, file, parentId, contactId){
        console.log('upload file: ' + file + ' to parent: ' + parentId);
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function
        if (file.size > self.MAX_FILE_SIZE) {
            cmp.set("v.errorMsg", 'Error : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
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
            self.uploadProcess(cmp, file, fileContents, parentId, contactId);

        });

        objFileReader.readAsDataURL(file);
    },

    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId, parentId, contactId) {
        console.log('uploadInChunk with file: ' + JSON.stringify(file) + ' and parentId: ' + parentId);
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveChunk");
        action.setParams({
            parentId: parentId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            fCategory : component.get("v.fileCategory")
        });

        // set call back
        action.setCallback(this, function(response) {
            // store the response / Attachment Id
            attachId = response.getReturnValue();
            // console.log("attachId: " + attachId);
            component.set("v.fileId", attachId);
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start postion is still less then end postion
                // then call again 'uploadInChunk' method ,
                // else, diaply alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, parentId, contactId);
                } else {
                    this.sendAndUpload(component, contactId, parentId);
                }
                // handel the response errors
            } else if (state === "INCOMPLETE") {
                alert("From server: " + response.getReturnValue());
                cmp.set("v.processing", false);
            } else if (state === "ERROR") {
                cmp.set("v.processing", false);
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

    uploadProcess: function(component, file, fileContents, parentId, contactId) {
        console.log('uploadProcess with file: ' + file + ' and parentId: ' + parentId);
        // set a default size or startpostiton as 0
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', parentId, contactId);
    },



    sendAndUpload : function(cmp, contactId, logId){
        console.log('sendAndUpload...');
        console.log('fileId: ' + cmp.get("v.fileId"));
        console.log('logId: ' + logId);
        var action = cmp.get("c.sendInfoEmail");
        action.setParams({
            "contactId" : contactId,
            "logId" : logId,
            "fileId" : cmp.get("v.fileId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success sending email');
                cmp.set("v.requestSent", true);
                cmp.set("v.processing", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
                cmp.set("v.processing", false);
            }
            else if (state === "ERROR") {
                cmp.set("v.processing", false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve data: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    validateForm : function(cmp,event){
        console.log('validating form...');
        var isValid = true;
        var issueType = cmp.find("incidentTypes");
        console.log('issueTpye: ' + issueType.get("v.value"));
        if(issueType.get("v.value")==null || issueType.get("v.value")==undefined || issueType.get("v.value")==''){

            console.log('issue type is null');
            isValid = false;
            issueType.showHelpMessageIfInvalid();
        } else {
            console.log('issue type is not null');
        }
        console.log("isValid: " + isValid);


        console.log('contact: ' + cmp.get("v.contact"));
        if(cmp.get("v.contact")==null || cmp.get("v.contact")==undefined){
            var contactMethod = cmp.get("v.selectedMethod");
            if(contactMethod == 'phone'){
                var phone = cmp.find("phone");
                if(phone.get("v.value")==null || phone.get("v.value")==undefined || phone.get("v.value")==''){

                    isValid = false;
                    phone.showHelpMessageIfInvalid();
                }
            }

            var fullName = cmp.find("name");
            console.log('fullName: ' + fullName.get("v.value"));
            if(fullName.get("v.value")==null || fullName.get("v.value") == undefined || fullName.get("v.value")==''){
                isValid= false;
                fullName.showHelpMessageIfInvalid();
            }

            var email = cmp.find("email");
            if(email.get("v.value")==null || email.get("v.value")==undefined || email.get("v.value")==''){
                isValid = false;
                email.showHelpMessageIfInvalid();
            }

        }
        console.log('isValid: ', isValid);
        return isValid;
    },

    /**
     * @purpose Creates error message toast
     * @param cmp
     * @param event
     * @param message
     */
    createErrorToast : function(cmp, event, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },
})