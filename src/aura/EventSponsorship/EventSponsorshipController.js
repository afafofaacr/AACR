/**
 * Created by afaf.awad on 4/22/2021.
 */

({
    doInit : function (cmp,event,helper){

        let action = cmp.get("c.getSponsorSetting");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                cmp.set('v.instructions', data);
                helper.buildSponsorsTable(cmp);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    },


    handleOnLoad : function (cmp,event,helper){
        helper.toggleButtons(cmp);
    },

    changeLevels : function(cmp,event,helper){
        helper.toggleButtons(cmp);
    },

    handleSubmit : function(cmp,event,helper){
        event.preventDefault();
        let validated = true;
        validated = validateSponsor(cmp.find('sponsorField2').get("v.value"), 2);
        validated = validateSponsor(cmp.find('sponsorField3').get("v.value"), 3);

        if(validated){
            cmp.find('eventSponsorForm').submit();
        }

        function validateSponsor(field, level){
            if(!field){
                console.log('check sponsor levels...');
                if(checkSponsorLevels(level)){
                    cmp.set("v.isOpen", true);
                    cmp.find('clearSponBtn').set("v.value", level);
                    return false;
                }else{
                    return true;
                }
            }else{
                return true;
            }
        }

        function checkSponsorLevels(sponLevel){
            let sponsorData = cmp.get('v.sponsorsData');
            let sponsorArray =[];
            let exists = false;

            sponsorData.forEach(function row(s){
                sponsorArray.push(s);
            });

            console.log('sponLevel == ' + sponLevel);
            for (let i=0; i < sponsorData.length; i++){
                if(sponsorData[i].Level__c == sponLevel){
                    console.log('sposnor exists!');
                    exists = true;
                    break;
                }
            };

            return exists;

            // console.log('sponsorData == ' + JSON.stringify(sponsorData));
            // while(level != sponLevel || i < sponsorData.length()){
            //     console.log('iterator ===== ' + i);
            //     console.log('sponsorData == ' + JSON.stringify(sponsorData[i]));
            //     level = sponsorData[i].Level__c;
            //     i++;
            // }
        }



    },

    handleOnSuccess: function(cmp,event,helper){
        helper.toggleButtons(cmp);
    },

    addSponsor: function(cmp,event,helper){
        let level = event.getSource().getLocalId();
        console.log(level.slice(- 1));
        cmp.set("v.level", level.slice(- 1));
        cmp.set('v.isSponsorDisabled', false);
        cmp.set('v.sponsorId','');
        cmp.set('v.sponsorFileId', '');
        cmp.find('event').set("v.value", cmp.get('v.recordId'));
        cmp.find('levelNum').set("v.value",level.slice(- 1));
    },

    handleUploadFinished: function (cmp, event, helper) {
        let uploadedFiles = event.getParam("files");
        cmp.set("v.sponsorFileId", uploadedFiles[0].documentId);
        cmp.find("logoId").set("v.value", uploadedFiles[0].documentId);

        console.log('docId = ' + uploadedFiles[0].documentId);
        helper.setFileAccessSettings(cmp, uploadedFiles[0].documentId);

    },

    populateDisplay : function(cmp,event,helper){
        console.log('populate display...');
      let sponsor = cmp.find('account').get('v.value');
        let action = cmp.get("c.getAccountInfo");
        action.setParams({
            'accId' : sponsor
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let acc = response.getReturnValue();
                cmp.set('v.account', acc);
                cmp.find('displayAs').set('v.value', acc.Name);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
            }
        });
        $A.enqueueAction(action);
    },

    handleOnLoadSponsor: function(cmp,event,helper){
        // helper.loadEditForm(cmp);
        console.log('handle onload sponsor...');
        console.log('sponsorId = ' + cmp.get('v.sponsorId'));
        // cmp.find('levelNum').set("v.value", cmp.get('v.level'));
        if (cmp.get('v.sponsorId')) {
            console.log('sponsor ID exists');
            cmp.find('event').set("v.value", cmp.get('v.recordId'));
            cmp.set("v.sponsorFileId", cmp.find("logoId").get("v.value"));
            // console.log('displayAs ' + cmp.find('displayAs').get("v.value"));
        }

    },

    handleSubmitSponsor: function(cmp,event,helper){
        if(helper.validate(cmp)){
            cmp.find('sponsorForm').submit();
        };

    },

    handleSuccessSponsor: function(cmp,event,helper){
        let record = event.getParam("response");
        // cmp.set('v.saving', true);
        cmp.set('v.sponsorId', '');
        cmp.set('v.sponsorFileId', '');
        cmp.find('account').set("v.value", '');
        cmp.find('displayAs').set("v.value", '');
        cmp.find('logoUrl').set("v.value", '');
        cmp.find('logoId').set("v.value",'');
        // helper.loadEditForm(cmp);
       helper.buildSponsorsTable(cmp);
        console.log('Sponsor Saved!');
    },

    actionRow: function(cmp,event,helper){
        let action = event.getParam('action');
        let record = event.getParam('row');
        switch (action.name) {
            case 'edit':
                helper.editRecord(cmp,record);
                break;
            case 'delete':
               helper.deleteRecord(cmp,record);
                break;
        }
    },

    handleSort: function(cmp, event, helper) {
        console.log('Sorting...');
        let sortedBy = event.getParam('fieldName');
        let sortDirection = event.getParam('sortDirection');

        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
        helper.sortData(cmp, sortedBy, sortDirection);
    },

    closeModel: function(cmp, event, helper) {
        cmp.set("v.isOpen", false);
    },

    clearSponsors: function(cmp, event, helper) {
        console.log('Clearing sponsors for level ' + cmp.find('clearSponBtn').get('v.value'));
        cmp.set('v.processing', true);
        let action = cmp.get("c.clearSponsorLevel");
        action.setParams({
            "eventId": cmp.get('v.recordId'),
            "level" : cmp.find('clearSponBtn').get('v.value')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    console.log('records deleted!');
                    cmp.set('v.processing', false);
                    cmp.set("v.isOpen", false);
                    cmp.find('eventSponsorForm').submit();
                    helper.buildSponsorsTable(cmp);
                }
                else{
                    console.log('could not delete record');
                }
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getImages");
            } else if (state === "ERROR") {
                let errors = response.getError();
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
    },

});