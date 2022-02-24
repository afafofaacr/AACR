/**
 * Created by afaf.awad on 6/5/2020.
 */

({

    doInit: function (cmp, event, helper) {
        cmp.set('v.eventId', helper.getEventId(cmp));
        console.log('eventid = ' + cmp.get('v.eventId'));
    },

    reInit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    getAllRecords: function (cmp, event, helper) {
        var Ids = cmp.get('v.aacrIdList');

        if(cmp.get('v.dupContacts').length > 0){
        var selectedRows = cmp.find('dupsTable').getSelectedRows();

        console.log('SelectedRecords = ' + JSON.stringify(selectedRows));

        if (helper.validateSelection(cmp, event, selectedRows) === true) {
            var selected_records = [];
            var IdList = [];

            Ids.forEach(function (id) {
                IdList.push(id);
            });

            selectedRows.forEach(function (row) {
                IdList.push(row.AACR_ID__c);
                selected_records.push(row.Id);
            });

            cmp.set("v.selectedRows", selected_records);
        }
            helper.getListofContactstoCreate(cmp, IdList);

        }else{
            helper.getListofContactstoCreate(cmp, Ids);
        }

        if(cmp.get('v.missingContacts').length > 0){
            console.log('Downloading File...');
            var downloadcsv = cmp.find('downloadCheckbox').get('v.checked');
            if (downloadcsv === true) {
                helper.downloadCSV(cmp);
            }
        }


    },

    addSelection: function (cmp, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        helper.validateSelection(cmp, event, selectedRows);
    },

    onDragOver: function (component, event, helper) {
        event.preventDefault();
    },

    onDrop: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        // event.dataTransfer.dropEffect='copy';
        var files = component.get('v.FileList');
        console.log('files = ' + JSON.stringify(files));
        // event.dataTransfer.files;
        helper.readFile(component, helper, files[0]);
    },

    processFileContent: function (component, event, helper) {
        if (component.get('v.showFile')) {
            var inputCmp = component.find("fileInput");
            var value = inputCmp.get("v.value");
            if (!value) {
                inputCmp.reportValidity();
            }
        } else {
            var allValid = component.find('fieldToMap').reduce(function (validSoFar, inputCmp) {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if (allValid) {
                var fieldList = [];
                fieldList.push(component.get('v.aacrField'));
                fieldList.push(component.get('v.emailField'));
                for (var i = 0; i < fieldList.length - 1; i++) {
                    if (fieldList[i + 1] === fieldList[i]) {
                        allValid = false;
                        helper.callErrorMsg(component, "You've choosen the same columns. Please review you field choices.");
                    }
                }
                if (allValid) {
                    var tableheaders = component.get("v.tableheaders");
                    var headerArray = tableheaders.values();
                    fieldList = [];
                    for (var value of headerArray) {
                        fieldList.push(value.value);
                    }
                    component.set('v.processing', true);
                    helper.validateFile(component,event,fieldList);

                }
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
        helper.goBacktoEvent(cmp);
    },

    goBack: function (cmp, event, helper) {
        var showValidation = cmp.get('v.showValidation');
        var showConfirm = cmp.get('v.showConfirm');

        if (showValidation) {
            cmp.set('v.showValidation', false);
            cmp.set('v.showPreview', true);
        }

        if (showConfirm) {
            if (cmp.get('v.dupContacts').length == 0 && cmp.get('v.missingContacts').length == 0) {
                cmp.set('v.showConfirm', false);
                cmp.set('v.showPreview', true);
            } else {
                cmp.set('v.showConfirm', false);
                cmp.set('v.showValidation', true);
            }
        }
    },

    createRecords: function (cmp, event, helper) {
        cmp.set('v.processing', true);
        console.log('eventId = ' + cmp.get('v.eventId'));
        var action = cmp.get("c.createAttendees");

        action.setParams({
            contacts: cmp.get('v.confirmList'),
            eventId: cmp.get('v.eventId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('CreateRecords SUCCESS!');
                var attendeeSize = response.getReturnValue();
                // console.log('attendeeSize = ' + attendeeSize);

                helper.goBacktoEvent(cmp);

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success!',
                    message: 'Attendee Records Created.',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();

            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
                console.log('State is INCOMPLETE');
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

});