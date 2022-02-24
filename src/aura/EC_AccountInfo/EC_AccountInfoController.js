/**
 * Created by afaf.awad on 2/3/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('doInit...');
        var exId = helper.getExhibitorId(cmp);
        cmp.set('v.exhibitorId', exId);
        var action = cmp.get("c.getExhibitorSettings");
        // action.setParams({
        //     exhibitorId: exId,
        // });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                if (results) {
                    console.log('results == ' + JSON.stringify(results));
                    cmp.set('v.exhibitorId', results.exSet.Id);
                    cmp.set('v.emailInput', results.exSet.Exhibitor_Email__c);
                    if(results.conDoc) {
                        cmp.set('v.fileId', results.conDoc.Id);
                        cmp.set('v.fileName', results.conDoc.Title);
                    }
                    if(results.exSet.Exhibitor_Email__c && !results.exSet.Verified_Email__c){
                        cmp.set('v.isVerified', true);
                    }else if(results.exSet.Verified_Email__c){
                        cmp.set('v.verifyComplete', true);
                    }
                }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
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
    },

    verifyEmail: function (cmp, event, helper) {
        console.log('Verify Email...');
        var emailInput = cmp.get('v.emailInput');
        console.log('emailInput == ' + emailInput);
        var action = cmp.get("c.verifyExhibitorEmail");
        action.setParams({
            emailString: emailInput,
            ecSettingId: cmp.get('v.exhibitorId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var results = response.getReturnValue();
                if (results) {
                    cmp.set('v.isVerified', true);
                    console.log('results == true');

                    var elem = cmp.find('verifyButton');
                    console.log('element = ' + elem);
                    // $A.util.addClass(elem, 'verifyButtonGreen');
                    // $A.util.removeClass(elem, 'verifyButton');

                }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
                console.log('INCOMPLETE');
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
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

    },

    handleOnLoad: function(cmp, event, helper){
        // var recUi = event.getParam("recordUi");
        // for(var idx = 1; idx <= 6; idx++){
        //     var sig = recUi.record.fields["Signature_" + idx + "__c"].value;
        //     if(sig!=null && sig!=undefined){
        //         var sigarray = sig.split('<br/>');
        //         cmp.find("sig" + idx).set("v.value", sigarray[0]);
        //         cmp.find("sig" + idx + 'Title').set("v.value", sigarray[1]);
        //     }
        // }
    },

    handleUploadFinished : function(cmp, event, helper){
        console.log('handleUploadFinished...');
        var fileName;
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        cmp.set("v.fileName", fileName);
        helper.uploadHelper(cmp, event);

        //If I need to make file access public
        // helper.setFileAccessSettings(cmp, event, uploadedFiles[0].documentId, 'main');

    },

    toggleReplyTo : function(cmp,event,helper){
        console.log('togglereplyTo...');
      let toggleVal = cmp.get('v.replyChoice');
      switch (toggleVal) {
            case 'noReply':
                cmp.find('replyTo').set('v.value', 'noreply@noreply.com');
                break;
            case 'reply':
                cmp.find('replyTo').reset();
                break;
        }
    },

    handleRemoveFile: function (cmp,event,helper){
            var action = cmp.get("c.removeFile");
            action.setParams({
                "fileName": cmp.get("v.fileName"),
                "recordId" : cmp.get("v.exhibitorId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.fileName", null);
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

    cancel : function(cmp,event,helper){
        window.history.back();
    },

    handleSave : function(cmp, event, helper){
        console.log('handleSave...');
        if(helper.validate(cmp)) {
            cmp.set('v.processing', true);
            cmp.find('accConfig').submit();
        }
        // helper.updateExSetHelper(cmp, cmp.get('v.exhibitorId'));
    },

    handleSuccess : function(cmp,event,helper){
        console.log('SUCCESS!!');
        window.location.href = '/ExhibitorDashboard';
    }

});