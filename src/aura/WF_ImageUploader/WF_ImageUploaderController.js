/**
 * Created by afaf.awad on 11/17/2021.
 */

({
    doInit : function(cmp,event,helper){
        // console.log('image field == ' + JSON.stringify(cmp.get('v.recordObj')));
        var name ='c__survey';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            cmp.set('v.surveyId', SOId);
        }
    },

    handleUploadFinished: function (cmp, event, helper) {
        let uploadedFiles = event.getParam("files");
        // let fieldDetails = cmp.get('v.recordObj');
        // fieldDetails.imageId = uploadedFiles[0].documentId;
        // cmp.set('v.recordObj', fieldDetails);

        console.log('docId = ' + uploadedFiles[0].documentId);

        let action = cmp.get("c.setImageToPublic");
        action.setParams({
            "fileId": uploadedFiles[0].documentId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let docId = response.getReturnValue();
                // let fieldDetails = cmp.get('v.recordObj');
                // fieldDetails.imageId = docId;
                // cmp.set('v.recordObj', fieldDetails);
                cmp.set('v.imageId', docId);
                cmp.find('imageId').set('v.value',docId);
                console.log('new ImageId == ' + docId);
                cmp.find('SurveyQuestionImage').submit();


            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: setImageToPublic');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleSuccess : function (cmp,event,helper){
        console.log('SurveyQuestion Saved!');
        let record = event.getParam("response");
        let fieldDetails = cmp.get('v.recordObj');
        // console.log('returned record = ' + JSON.stringify(record.fields));
        //Set sq fields
        fieldDetails.sqId = record.id;
        fieldDetails.sqRecord = {};
        fieldDetails.sqRecord.Label__c = record.fields.Label__c.value;
        fieldDetails.sqRecord.Question_Responses__c = record.fields.Question_Responses__c.value;
        fieldDetails.sqRecord.Question_Type__c = record.fields.Question_Type__c.value;
        fieldDetails.sqRecord.ImageId__c = record.fields.ImageId__c.value;
        fieldDetails.sqRecord.isBold__c = record.fields.isBold__c.value;
        fieldDetails.sqRecord.isRequired__c = record.fields.isRequired__c.value;

        cmp.set('v.recordObj', fieldDetails);

        console.log('saved image record == ' + JSON.stringify(cmp.get('v.recordObj')));

        let appEvent = $A.get("e.c:WF_AppEvent");
        appEvent.setParams({
            'field' : fieldDetails
        });
        appEvent.fire();

    },


});