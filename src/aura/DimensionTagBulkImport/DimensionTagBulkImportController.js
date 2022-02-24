/**
 * Created by afaf.awad on 6/8/2021.
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
        helper.closeModal(cmp);
    },

    goBack: function (cmp, event, helper) {
          cmp.set('v.showConfirm', false);
          cmp.set('v.showPreview', true);
    },

    createRecords: function (cmp, event, helper) {
        cmp.set('v.processing', true);
        console.log('IdList = ' + JSON.stringify(cmp.get('v.idList')));
        let dimTag = cmp.get('v.DimTag');
        let action = cmp.get("c.createTagRecords");

        action.setParams({
            stringRecordIds: JSON.stringify(cmp.get('v.idList')),
            dimTagId: dimTag.Id

        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('Returned results == ' + JSON.stringify(data));
                let toastEvent = $A.get("e.force:showToast");
                if(!data.success) {
                    helper.downloadCSV(cmp, data.importResults);
                    toastEvent.setParams({
                        type: "error",
                        title: "Error!",
                        message: "An error was found with one or more records. See downloaded file for more details.",
                        mode: "sticky"

                    });
                }else {
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Tags Created Successfully!',
                        duration: '6000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'dismissible'
                    });
                }
                toastEvent.fire();
                helper.closeModal(cmp);

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
    },
});