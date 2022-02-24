/**
 * Created by afaf.awad on 2/3/2021.
 */

({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
    CHUNK_SIZE: 750000,      //Chunk Max size 750Kb

    getExhibitorId : function(cmp){
        var name ='exId';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },

    uploadHelper: function(component, event) {
        console.log('Upload Helper...');
        // start/show the loading spinner
        component.set("v.processing", true);
        // get the selected files using aura:id [return array of files]
        var fileInput = component.find("logoFile").get("v.files");
        // get the first file using array index[0]
        var file = fileInput[0];
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function
        if (file.size > self.MAX_FILE_SIZE) {
            component.set("v.processing", false);
            component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
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
            self.uploadProcess(component, file, fileContents);
        });

        objFileReader.readAsDataURL(file);
    },

    uploadProcess: function(component, file, fileContents) {
        console.log('upload Process...');
        // set a default size or startpostiton as 0
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },


    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        console.log('uploadInChunck....');
        console.log('exhibitorId = ' + component.get("v.exhibitorId") );
        component.set('v.fileId',null);
        // call the apex method 'saveChunk'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.uploadLogoImage");
        action.setParams({
            exhibitorId: component.get("v.exhibitorId"),
            fileId: attachId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fCategory : component.get("v.fileCategory"),
            contentDocumentId : file.Id

        });
        console.log('setting Callback for uploadLogoImage...');
        // set call back
        action.setCallback(this, function (response) {
            // store the response / Attachment Id
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('upload successful. Id = ' + attachId);
                // update the start position with end position
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                // check if the start position is still less then end position
                // then call again 'uploadInChunk' method ,
                // else, display alert msg and hide the loading spinner
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
                } else {
                    component.set('v.fileId', attachId);
                    component.set("v.processing", false);
                }
                // handle the response errors
            } else if (state === "INCOMPLETE") {
                console.log("From server: " + response.getReturnValue());
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

    updateExSetHelper : function(cmp, exhibitorId){
        console.log('Saving signatures...');
        var sig1 = cmp.find("sig1").get("v.value");
        if(sig1!=''){
            var sig1Title = cmp.find("sig1Title");
            console.log('sig1Title: ' + sig1Title);
            if(sig1Title.get("v.value")!=''){
                sig1 += '<br/>' + sig1Title.get("v.value");
            }
        }
        // console.log('sig1: ' + sig1);
        var sig2 = cmp.find("sig2").get("v.value");
        if(sig2!=''){
            var sig2Title = cmp.find("sig2Title");
            // console.log('sig2Title: ' + sig2Title);
            if(sig2Title.get("v.value")!=''){
                sig2 += '<br/>' + sig2Title.get("v.value");
            }
        }
        // console.log('sig2: ' + sig2);
        var sig3 = cmp.find("sig3").get("v.value");
        if(sig3!=''){
            var sig3Title = cmp.find("sig3Title");
            // console.log('sig3Title: ' + sig3Title.get("v.value"));
            if(sig3Title.get("v.value")!=''){
                sig3 += '<br/>' + sig3Title.get("v.value");
            }
        }
        // console.log('sig3: ' + sig3);
        var sig4 = cmp.find("sig4").get("v.value");
        if(sig4!=''){
            var sig4Title = cmp.find("sig4Title");
            // console.log('sig4Title: ' + sig4Title.get("v.value"));
            if(sig4Title.get("v.value")!=''){
                sig4 += '<br/>' + sig4Title.get("v.value");
            }
        }
        // console.log('sig4: ' + sig4);
        var sig5 = cmp.find("sig5").get("v.value");
        if(sig5!=''){
            var sig5Title = cmp.find("sig5Title");
            // console.log('sig5Title: ' + sig5Title.get("v.value"));
            if(sig5Title.get("v.value")!=''){
                sig5 += '<br/>' + sig5Title.get("v.value");
            }
        }
        // console.log('sig5: ' + sig5);
        var sig6= cmp.find("sig6").get("v.value");
        if(sig6!=''){
            var sig6Title = cmp.find("sig6Title");
            // console.log('sig6Title: ' + sig6Title.get("v.value"));
            if(sig6Title.get("v.value")!=''){
                sig6 += '<br/>' + sig6Title.get("v.value");
            }
        }
        // console.log('sig6: ' + sig6);

        var action = cmp.get("c.updateExhibitorSigs");
        action.setParams({
            "exSetId": exhibitorId,
            "message" : 'test message',
            // "message" : cmp.find("inviteMessage").get("v.value"),
            "sig1" : sig1,
            "sig2" : sig2,
            "sig3" : sig3,
            "sig4" : sig4,
            "sig5" : sig5,
            "sig6" : sig6
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + data);
                if(data) {
                    console.log('SUCCESS!!');
                    window.location.href = '/ExhibitorDashboard';
                }else{
                    cmp.set('v.processing', false);
                }
            } else if (state === "INCOMPLETE") {
                // do something
                return false;
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
                return false;
            }
        });
        $A.enqueueAction(action);
    },

    validate : function(cmp) {
        console.log('validating settings info...');
        let isValid = true;

        let validateField = auraId => {
            var field = cmp.find(auraId);
            var fieldVal = field.get("v.value");
            if (!fieldVal) {
                $A.util.addClass(field, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(field, 'slds-has-error');
            }
            return isValid;
        }

        var sendName = validateField('senderName');
        var replyTo = validateField('replyTo');
        var invoiceTo = validateField('invoiceTo');

        if(!sendName || !replyTo || !invoiceTo) {
            isValid = false;
        }

        console.log('isvalid = ' +  isValid);
        console.log('emailInput == ' + cmp.get('v.emailInput'));

        if(!cmp.get('v.emailInput')) {
            $A.util.addClass(cmp.find('verifyEmail'), 'slds-has-error');
            isValid = false;
        }else{
            $A.util.removeClass(cmp.find('verifyEmail'), 'slds-has-error');
            }


        console.log('isvalid = ' +  isValid);

        return isValid;
    },



});