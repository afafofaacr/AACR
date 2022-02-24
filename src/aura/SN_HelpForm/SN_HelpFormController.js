/**
 * Created by lauren.lezberg on 9/3/2019.
 */
({

    doInit : function(cmp, event, helper){
        console.log("initializing new record...");
        //create new error log
        cmp.find("LogRecordCreator").getNewRecord(
            "AACR_Error_Log__c", // sObject type
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = cmp.get("v.newLog");
                var error = cmp.get("v.newLogError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
            })
        );

        var action = cmp.get("c.getInitialHelpFormData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var initialData = response.getReturnValue();
                cmp.set("v.contact", initialData.currentContact);
                cmp.set("v.incidentTypes", initialData.incidentTypes);
                cmp.set("v.defaultOwnerId", initialData.defaultOwnerId);
                cmp.set("v.maintenanceMessage", initialData.maintenanceMessage);
                cmp.set("v.ITHelpLink", initialData.helpFormLink);

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            }
            else if (state === "ERROR") {
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

    saveErrorLog : function(cmp,event, helper){
        console.log('saveErrorLog...');

        var logRecord = {};

        logRecord.Issue_Description__c = cmp.get("v.simpleNewLog").Issue_Description__c;

        var incidentTypeName;
        var incidentId = cmp.find("incidentTypes").get("v.value");
        cmp.get("v.incidentTypes").forEach(function(type){
            if(type.Id == incidentId){
                incidentTypeName = type.Type__c;
            }
        });

        if(helper.validateForm(cmp, event)) {
            console.log('valid form...');
            cmp.set("v.processing", true);

            var contact = cmp.get("v.contact");
            var method = cmp.get("v.selectedMethod");

            //set url
            if(document.referrer!=null && document.referrer!='' && document.referrer!=undefined) {
                logRecord.URL__c = document.referrer;
            } else {
                logRecord.URL__c = window.location.href;
            }

            logRecord.Incident_Id__c = incidentId;
            logRecord.Incident_Type__c = incidentTypeName;

            var name= cmp.find("name").get("v.value");
            var email = cmp.find("email").get("v.value");

            logRecord.Contact_Name__c = name;
            logRecord.Contact_Email__c = email;
            logRecord.Contact_Phone__c = cmp.find("phone").get("v.value");


            if (method == 'phone') {
                logRecord.Contact_Method__c = 'Phone'
            } else {
                logRecord.Contact_Method__c = 'Email';
            }

            //if there is a contact record present
            if(contact!=null) {

                logRecord.Contact__c = contact.Id;
                logRecord.Affiliation__c = contact.Account.Name;

                cmp.set("v.simpleNewLog", logRecord);
                helper.saveLogRecord(cmp, event);

            } else {
                //search for contact in system
                var action = cmp.get("c.findContact");
                action.setParams({
                    "name": name,
                    "email": email
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        contact = response.getReturnValue();
                        //if contact is found
                        if (contact != null) {
                            cmp.set("v.contact", contact);
                            logRecord.Contact__c = contact.Id;
                            logRecord.Affiliation__c = contact.Account.Name;
                        } else {
                            if(cmp.find('accountLookup')!=undefined) {
                                logRecord.Affiliation__c = cmp.find("accountLookup").get("v.selectedId");
                            }
                        }
                        
                        cmp.set("v.simpleNewLog", logRecord);
                        helper.saveLogRecord(cmp, event);

                    } else {
                        console.log('error');
                        helper.createErrorToast(cmp, event, 'Error finding contact.');
                        cmp.set("v.processing", false);
                    }
                });
                $A.enqueueAction(action);
            }
        } else {
            console.log('invalid form data');
            helper.createErrorToast(cmp, event, 'Invalid Form Data');

        }
    },

    goToProfile : function(cmp, event, helper){
        window.location.href = '/apex/MemberProfile';
    },

    resetForm : function(cmp ,event, helper){
        window.location.reload(true);

    },

    handleUpload : function(cmp, event, helper){
        console.log('handleUPload...');
        cmp.set("v.uploading", true);
        var fileTypes = cmp.get("v.acceptedFileTypes");
        var file = event.getSource().get("v.files")[0];

        console.log('fileSzie: ' + file.size/1000000);
        if (file.size > helper.MAX_FILE_SIZE) {
            console.log("file too big");
            cmp.set("v.uploading", false);
            cmp.set("v.fileName", null);
            cmp.set("v.fileId", null);
            cmp.set("v.FileList", null);
            cmp.set("v.errorMsg", 'Error : File size cannot exceed ' + helper.MAX_FILE_SIZE/1000000 + ' MB.\n' + ' Selected file size: ' + file.size/1000000 + ' MB');
            return;
        }

        //check the file is of a valid type
        if(fileTypes.includes(file.type) && file.type!=null && file.type != '') {
            cmp.set("v.fileAttach", file);
            cmp.set("v.fileName", file.name);
            $A.util.removeClass(cmp.find('fileInput'), 'customError');
            cmp.set("v.errorMsg", null);
        } else {
            cmp.set("v.errorMsg", 'This file type is not accepted. Please try another file.');
        }

        cmp.set("v.uploading", false);
    },

    removeFileAttachment : function(cmp, event, helper){
        cmp.set("v.fileName", null);
        cmp.set("v.fileId", null);
        cmp.set("v.FileList", null);

    }
})