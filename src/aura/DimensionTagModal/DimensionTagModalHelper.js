/**
 * Created by afaf.awad on 6/1/2021.
 */

({
    validateFields: function(cmp, buttonId){
        //reset errors
        let inputField = cmp.find('tagName');
        inputField.setCustomValidity('');
        inputField.reportValidity();

        if(this.validateRequiredFields(cmp)){
            this.validateTagName(cmp, buttonId);
        }
    },

    validateRequiredFields: function(cmp){

        function validateFields(auraId) {
            let inputField = cmp.find(auraId);
            console.log('inputField = ' + inputField.get('v.value'));
            let validity = inputField.get("v.validity");
            if(!validity.valid) {
                inputField.reportValidity();
            }
            return validity.valid;
        }

        let auraIds=['tagName', 'tagType', 'tagDescription'];
        let allValid=[];
        auraIds.forEach(function (item){
            allValid.push(validateFields(item));
        });

        console.log('allValid == ' + allValid);

        if (allValid.includes(false)) {
            return false;
        } else {
            return true;
        }

    },

    validateTagName : function(cmp, buttonId){
        let action = cmp.get("c.validateTagName");
        action.setParams({
            'tagName': cmp.get('v.tagName'),
            'objectName' : cmp.get('v.objectName'),
            'visibility' : cmp.get('v.visibilityChoice'),
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let isValid = response.getReturnValue();
                if(isValid) {
                    console.log('Tag Name is valid == ' + isValid);
                    this.saveTag(cmp, buttonId);
                }else {
                    let inputField = cmp.find('tagName');
                    inputField.setCustomValidity('This Tag name already exists.');
                    inputField.reportValidity();
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - validation: ');
                return false;
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - validation: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: validation");
                }
                return false;
            }
        });
        $A.enqueueAction(action);

    },

    saveTag : function(cmp, buttonId){
        cmp.set('v.processing', true);
        console.log('objectName= ' + cmp.get('v.objectName'));
        console.log('objectChoice= ' + cmp.get('v.objectChoice'));
        let objectName = cmp.get('v.objectName') == '' ? cmp.get('v.objectChoice') : cmp.get('v.objectName');
        console.log('object value= ' + objectName);
        let action = cmp.get("c.createDimTag");
        action.setParams({
            'recLabel': cmp.get('v.tagName'),
            'description': cmp.find('tagDescription').get('v.value'),
            'objectName': objectName,
            'visibility': cmp.get('v.visibilityChoice'),
            'recordId': cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success!!');
                if (buttonId == 'saveBtn') {
                    cmp.set('v.processing', false);
                    this.closeModal(cmp);

                } else {
                    cmp.set('v.tagName', '');
                    cmp.set('v.objectChoice', cmp.get('v.objectName') ? cmp.get('v.objectName') : '');
                    cmp.find('tagDescription').set('v.value', '');
                    cmp.set('v.visibilityChoice', 'public');
                    cmp.set('v.processing', false);

                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - saveModal: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - saveModal: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: saveModal");
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeModal : function(cmp){
        console.log('closing modal...');
        cmp.set("v.isOpen", false);
        let cmpEvent = cmp.getEvent('callDimTagEvent');
        cmpEvent.setParams({
            'action' : 'refresh'
        })
        cmpEvent.fire();

    },

    // createNewTag : function(cmp, buttonId){
    //     console.log('creating new tag....');
    //     // let buttonId = cmp.find('tagIdJob').get('v.value');
    //     console.log('buttonId: ' + buttonId);
    //     let action = cmp.get("c.createTagRecordFromNewDimTag");
    //     action.setParams({
    //         'recLabel': cmp.get('v.tagName'),
    //         'recordId' : cmp.get('v.recordId')
    //     });
    //     action.setCallback(this, function(response) {
    //         let state = response.getState();
    //         if (state === "SUCCESS") {
    //             let storeResponse = response.getReturnValue();
    //             console.log('storeResponse:: ' + JSON.stringify(storeResponse));
    //             if(storeResponse) {
    //                 if (buttonId == 'saveBtn') {
    //                     this.closeModal(cmp);
    //                     // let cmpEvent = cmp.getEvent('callDimTagEvent');
    //                     // cmpEvent.setParams({
    //                     //     'action' : 'refresh'
    //                     // })
    //                     // cmpEvent.fire();
    //                     // cmp.set("v.isOpen", false);
    //                 } else {
    //                     cmp.set('v.tagName', '');
    //                     cmp.find('tagDescription').set('v.value', '');
    //                     cmp.set('v.visibilityChoice', 'public');
    //                 }
    //             }else{
    //                 console.log('storeResponse empty:: ' + storeResponse);
    //             }
    //
    //         } else if (state === "INCOMPLETE") {
    //             console.log('Incomplete Callout: - createTag Helper: ');
    //         } else if (state === "ERROR") {
    //             let errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message - createTag Helper: " +
    //                         errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error: createTag Helper");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    //
    // },

});