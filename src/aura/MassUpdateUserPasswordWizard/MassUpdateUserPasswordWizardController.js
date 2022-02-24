/**
 * Created by afaf.awad on 7/13/2021.
 */

({
    doInit: function (cmp, event, helper) {
    },

    reInit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    onDragOver: function (component, event, helper) {
        event.preventDefault();
    },

    onDrop: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        // event.dataTransfer.dropEffect='copy';
        let files = component.get('v.FileList');
        // event.dataTransfer.files;
        helper.readFile(component, helper, files[0]);
    },


    processFileContent: function (component, event, helper) {
        if (component.get('v.showFile')) {
            let inputCmp = component.find("fileInput");
            let value = inputCmp.get("v.value");
            if (!value) {
                inputCmp.reportValidity();
            }
        } else {
            let inputCmp = component.find("idMap");
            let value = inputCmp.get("v.value");
            if (!value) {
                inputCmp.reportValidity();
            }else{
                let tableheaders = component.get("v.tableheaders");
                let headerArray = tableheaders.values();
                let fieldList = [];
                for (let value of headerArray) {
                    fieldList.push(value.value);
                }
                component.set('v.processing', true);
                helper.validateFile(component,event,fieldList);
            }
        }
    },

    clearError: function (cmp, event, helper) {
        helper.callErrorMsg(cmp, '');
    },

    removeFile: function (component, event, helper) {
        component.set("v.fileContentData", null);
        component.set("v.showFile", true);
        component.set("v.showPreview", false);
    },

    cancel: function (cmp, event, helper) {
        helper.closeModal(cmp, null);
    },

    goBack: function (cmp, event, helper) {
        cmp.set('v.showConfirm', false);
        cmp.set('v.showPreview', true);
    },

    updatePassword: function (cmp, event, helper) {
        if(helper.validatePassword(cmp)) {
            console.log('IdList = ' + JSON.stringify(cmp.get('v.idList')));
            cmp.set('v.processing', true);
            let action = cmp.get("c.callBatch_UpdatePasswords");
            action.setParams({
                idListString: JSON.stringify(cmp.get('v.idList')),
                password : cmp.get('v.password')
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let batchId = response.getReturnValue();
                    console.log('Returned results == ' + JSON.stringify(batchId));
                    helper.closeModal(cmp,batchId);
                    

                    // let toastEvent = $A.get("e.force:showToast");
                    // if (!data.success) {
                    //     helper.downloadCSV(cmp, data.importResults);
                    //     toastEvent.setParams({
                    //         type: "error",
                    //         title: "Error!",
                    //         message: "An error was found with one or more records. See downloaded file for more details.",
                    //         mode: "sticky"
                    //
                    //     });
                    // } else {
                    //     toastEvent.setParams({
                    //         title: 'Success',
                    //         message: 'Tags Created Successfully!',
                    //         duration: '6000',
                    //         key: 'info_alt',
                    //         type: 'success',
                    //         mode: 'dismissible'
                    //     });
                    // }
                    // toastEvent.fire();
                    // helper.closeModal(cmp);

                } else if (state === "INCOMPLETE") {
                    cmp.set('v.processing', false);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": "An Error has occurred. Please try again or contact System Administrator."
                    });
                    toastEvent.fire();

                } else if (state === "ERROR") {
                    cmp.set('v.processing', false);
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        "message": "An Error has occurred. Please try again or contact System Administrator."
                    });
                    toastEvent.fire();
                    let errors = response.getError();
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
        }
    },

    checkPassword : function(component, helper) {
        let inputField = component.find('pwValue');
        inputField.setCustomValidity('');
        inputField.reportValidity();

        //Get password
        var password = component.get("v.password");

        //Password strength
        let strength = {
            1: 'Invalid',
            2: 'Invalid',
            3: 'Invalid',
            4: 'Invalid',
            5: 'Valid'
        };

        //Password Strength Check
        let strengthValue = {
            'caps': false,
            'length': false,
            'special': false,
            'numbers': false,
            'small': false
        };

        //Password strength styles
        let passwordStrengthStyle = {
            0: 'slds-theme_error',
            1: 'slds-theme_error',
            2: 'slds-theme_error',
            3: 'slds-theme_error',
            4: 'slds-theme_error',
            5: 'slds-theme_success'
        };

        //Check Password Length
        if(password.length >= 8) {
            strengthValue.length = true;
        }

        //Calculate Password Strength
        for(let index=0; index < password.length; index++) {
            let char = password.charCodeAt(index);
            if(!strengthValue.caps && char >= 65 && char <= 90) {
                strengthValue.caps = true;
            } else if(!strengthValue.numbers && char >=48 && char <= 57){
                strengthValue.numbers = true;
            } else if(!strengthValue.small && char >=97 && char <= 122){
                strengthValue.small = true;
            } else if(!strengthValue.numbers && char >=48 && char <= 57){
                strengthValue.numbers = true;
            } else if(!strengthValue.special && (char >=33 && char <= 47) || (char >=58 && char <= 64)) {
                strengthValue.special = true;
            }
        }

        let strengthIndicator = 0;
        for(let metric in strengthValue) {
            if(strengthValue[metric] === true) {
                strengthIndicator++;
            }
        }

        //get badge
        var psBadge = component.find('psBadge');

        //Remove style
        for(let strengthStyle in passwordStrengthStyle) {
            $A.util.removeClass(psBadge, passwordStrengthStyle[strengthStyle]);
        }

        //Add style
        $A.util.addClass(psBadge, passwordStrengthStyle[strengthIndicator]);

        //set password strength
        component.set("v.passwordStrength", strength[strengthIndicator]);
    }
});