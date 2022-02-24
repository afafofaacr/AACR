/**
 * Created by afaf.awad on 12/5/2019.
 */

({
    doInit: function(cmp, event, helper){
        let formGroupId = cmp.get("v.formGroupId");
        let field = cmp.get("v.fieldsList");

        if(formGroupId) {
            let fieldResponse = cmp.get("v.responseList");
            if (fieldResponse && fieldResponse.length) {
                if (field.PagesApi__Field__r.PagesApi__Type__c == 'file') {
                    cmp.set('v.isFileType', 'true');
                    helper.getAttachment(cmp, field.PagesApi__Response__c);
                }
                cmp.set('v.fieldResponse', field);
            } else {
                cmp.set("v.field", field);
                cmp.set("v.responded", false);
                if (field.PagesApi__Type__c == 'file') {
                    cmp.set('v.isFileType', 'true');
                }
            }
        }
    },

    /**
     * @Purpose: When user clicks Next/Previous button, function is called to validate field. If field passes validation,
     *              the field response is saved. Once save is successful, the validation is passed to helper,
     *              which calls ValidateEvt to pass info to BackOfficeForm cmp to collect in a validatedCheck List.
     * @param cmp
     * @param event
     * @param helper
     */

    handleSave : function(cmp, event, helper){
    let formGroupId = cmp.get("v.formGroupId");
    let valid = false;

    if (formGroupId) {
        let isFileType = cmp.get("v.isFileType");
        let fileObj = cmp.get("v.fileObj");
        if (isFileType){
            if(fileObj){
                valid = true;
            }else{
                cmp.set("v.errorMsg", 'Attachment is required');
            }
        } else {
            valid = [].concat(cmp.find("fieldInput")).reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        }

        if (valid) {
            let responseArray = [];
            let formField;
            let formId;
            let fieldId;
            let response;
            let fieldResponseId;

            if(cmp.get("v.responded") === false){
                formField = cmp.get("v.field");
                console.log('field in handleSave = ' + JSON.stringify(formField));
                fieldId = formField.Id;
                formId = formField.PagesApi__Form__c;
                fieldResponseId ='';
                if(fileObj){
                    response = fileObj[0].documentId;
                }else {
                    response = formField.value;
                    console.log('response = ' + response);
                }
            }else {
                formField = cmp.get("v.fieldResponse");
                fieldId = formField.PagesApi__Field__c;
                fieldResponseId = formField.Id;
                if(fileObj){
                    response = fileObj.documentId;
                }else {
                    response = formField.PagesApi__Response__c;
                }
            }

            responseArray.push({
                fieldObj: fieldId ,
                response: response,
                formId: formId,
                fieldResponseId: fieldResponseId
                });

            let action = cmp.get("c.createFieldResponses");
            action.setParams({
                "fieldResponses": JSON.stringify(responseArray),
                "formResponseId": cmp.get("v.formResponseId")
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                console.log('state =' + state);
                if (state === "SUCCESS") {
                    helper.validated(cmp, event, fieldId , valid);
                } else if (state === "INCOMPLETE") {
                    console.log('state =' + state);
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    console.log("Error message: " + errors[0].message);
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }

            });
            $A.enqueueAction(action);
        }
    }else{
        helper.validated(cmp, event, 'No Form' , true);
    }
},

    handleFileUpload : function(cmp, event, helper){

        let fileInput = event.getParam("files");
        let fileName = fileInput[0].name;

        if(fileInput){
            cmp.set("v.fileObj", fileInput);
            cmp.set("v.fileName", fileName);
            cmp.set("v.errorMsg", "");
        }

        console.log("fileInput = " + JSON.stringify(cmp.get('v.fileObj')));
    },


    removeFileAttachment : function(cmp, event, helper){
        helper.deleteFile(cmp, cmp.get("v.fileObj"));
    }

});