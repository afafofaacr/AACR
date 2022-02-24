/**
 * Created by afaf.awad on 10/11/2021.
 */

({

    doInit: function (cmp, event, helper) {
        console.log('doInit Modal....');
        //set custom label here so that button text can be updated in realtime.
        let label = cmp.get('v.customLabel');
        cmp.find('fieldLabel').set('v.value', label);

        //normalize field types
        const standardTypes = ['text', 'tel', 'date', 'number', 'email', 'checkbox'];
        let field = cmp.get('v.fieldDetails');
        let fieldType;
        if (standardTypes.includes(field.Field_Type__c)) {
            fieldType = 'standard';
        } else {
            fieldType = field.Field_Type__c;
        }
        cmp.set('v.fieldType', fieldType);

        //special logic for specific types.
        if(fieldType.includes('select')){
            cmp.find('questionType').set('v.value', fieldType == 'single-select' ? 'ssVertical' : 'msVertical');
            if (field.isUnique__c) {
                helper.getPicklistValues(cmp, field.API_Name__c);
            }
        }

        if(fieldType == 'button'){
            cmp.find('footButton').set('v.label', label);
        }

    },

    cancel : function(cmp,event,helper){
        helper.closeModal(cmp);
    },

    handleSave : function(cmp,event,helper){
        console.log('Saving SurveyQuestion...');
        console.log('Survey == ' + JSON.stringify(cmp.get('v.survey')));
        event.preventDefault();
        cmp.find('SurveyQuestionForm').submit();
    },


    handleSuccess : function (cmp,event,helper){
        console.log('SurveyQuestion Saved!');
        let record = event.getParam("response");
        let fieldDetails = cmp.get('v.fieldDetails');
        console.log('returned record = ' + JSON.stringify(record.fields));
        //Set sq fields
        fieldDetails.sqId = record.id;
        fieldDetails.sqRecord = {};
        fieldDetails.sqRecord.Label__c = record.fields.Label__c.value;
        fieldDetails.sqRecord.Question_Responses__c = record.fields.Question_Responses__c.value;
        fieldDetails.sqRecord.Question_Type__c = record.fields.Question_Type__c.value;
        fieldDetails.sqRecord.ImageId__c = record.fields.ImageId__c.value;
        fieldDetails.sqRecord.isBold__c = record.fields.isBold__c.value;
        fieldDetails.sqRecord.isRequired__c = record.fields.isRequired__c.value;
        // fieldDetails.dragId = fieldDetails.Id + record.id;
        console.log('dragId = ' + fieldDetails.dragId);
        cmp.set('v.fieldDetails', fieldDetails);
        helper.closeModal(cmp, fieldDetails);

    },

    handleUploadFinished: function (cmp, event, helper) {
        let uploadedFiles = event.getParam("files");
        let fieldDetails = cmp.get('v.fieldDetails');
        fieldDetails.imageId = uploadedFiles[0].documentId;
        cmp.set('v.fieldDetails', fieldDetails);

        console.log('docId = ' + uploadedFiles[0].documentId);
        helper.setFileAccessSettings(cmp, uploadedFiles[0].documentId);

    },

    showButtonText : function(cmp,event,helper){
        if(cmp.get('v.fieldType') == 'button'){
            let label = cmp.find('fieldLabel').get('v.value');
            console.log('showbuttontext ');
            // + cmp.find('footButton').set('v.label', label) );
            cmp.find('footButton').set('v.label', label)
        }
    }

});