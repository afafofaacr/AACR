/**
 * Created by afaf.awad on 1/20/2021.
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
        var compMap = cmp.get('v.idCompMap');
        var dupsMap = cmp.get('v.dupContactMap');
        var newCompMap = cmp.get('v.finalCompMap');

        if(cmp.get('v.dupContacts').length > 0){
            var selectedRows = cmp.find('dupsTable').getSelectedRows();

            console.log('SelectedRecords = ' + JSON.stringify(selectedRows));

            if (helper.validateSelection(cmp, event, selectedRows) === true) {
                //Need new arrays to keep user choices if they go Back and Next.
                var selected_records = [];
                var IdList = [];
                //adding the AACRIDs already validated to new List
                Ids.forEach(function (id) {
                    IdList.push(id);
                    newCompMap.push({key:id, value: compMap[id]});
                });

                //adding the AACRID of the selected contact from duplicates table
                selectedRows.forEach(function (row) {
                    IdList.push(row.AACR_ID__c);
                    selected_records.push(row.Id);
                    newCompMap.push({key:row.AACR_ID__c, value: dupsMap[row.AACR_ID__c]});
                    console.log('dupMap sample: ' + dupsMap[row.AACR_ID__c]);
                    //add selected id to idCompMap
                });

                console.log('fianlCompMap: ' + JSON.stringify(cmp.get('v.finalCompMap')));

                cmp.set('v.finalCompMap', newCompMap);
                cmp.set("v.selectedRows", selected_records);
            }
            helper.getListofContactstoCreate(cmp, IdList);

        }else{

            //adding the AACRIDs already validated to new List
            Ids.forEach(function (id) {
                newCompMap.push({key:id, value: compMap[id]});
            });

            cmp.set('v.finalCompMap', newCompMap);
            helper.getListofContactstoCreate(cmp, Ids);
        }

        if(cmp.get('v.missingContacts').length > 0){
            var downloadcsv = cmp.find('downloadCheckbox').get('v.checked');
            if (downloadcsv === true) {
                helper.downloadCSV(cmp);
            }
        }

        if(cmp.get('v.contactsNoUser').length > 0){
            var downloadcsv = cmp.find('downloadCheckboxNoUsers').get('v.checked');
            if (downloadcsv === true) {
                helper.downloadCSV_NoUsers(cmp);
            }
        }

        if(cmp.get('v.invalidCodes').length > 0){
            var downloadcsv = cmp.find('downloadCheckboxCodes').get('v.checked');
            if (downloadcsv === true) {
                helper.downloadCSV_NoCodes(cmp);
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
            var inputCmp = component.find("emailMap");
            var value = inputCmp.get("v.value");
            if (!value) {
                inputCmp.reportValidity();
            }else if(component.get('v.compCode') === component.get('v.emailField')) {
                helper.callErrorMsg(component, "You've chosen the same columns. Please review you field choices.");
            }else{
                var tableheaders = component.get("v.tableheaders");
                var headerArray = tableheaders.values();
                var fieldList = [];
                for (var value of headerArray) {
                    fieldList.push(value.value);
                }
                component.set('v.processing', true);
                helper.validateFile(component,event,fieldList);

            // var allValid = component.find('fieldToMap').reduce(function (validSoFar, inputCmp) {
            //     inputCmp.reportValidity();
            //     return validSoFar && inputCmp.checkValidity();
            // }, true);

            // if (allValid) {
                // var fieldList = [];
                // fieldList.push(component.get('v.compCode'));
                // fieldList.push(component.get('v.emailField'));
                // for (var i = 0; i < fieldList.length - 1; i++) {
                //     if (fieldList[i + 1] === fieldList[i]) {
                //         allValid = false;
                //         helper.callErrorMsg(component, "You've choosen the same columns. Please review you field choices.");
                //     }
                // }
                // if (allValid) {
                //     var tableheaders = component.get("v.tableheaders");
                //     var headerArray = tableheaders.values();
                //     var fieldList = [];
                //     for (var value of headerArray) {
                //         fieldList.push(value.value);
                //     }
                //     component.set('v.processing', true);
                //     helper.validateFile(component,event,fieldList);
                // }
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
        console.log('finalCompMap = ' + JSON.stringify(cmp.get('v.confirmList')));
        console.log('idCompMap = ' + JSON.stringify(cmp.get('v.idCompMap')));

        // if(cmp.get('v.finalCompMap').length == 0 ) {
        //     let compMap = cmp.get('v.idCompMap');
        //     let confirmList = cmp.get('v.confirmList');
        //     let newCompMap = [];
        //     confirmList.forEach(function(row) {
        //         newCompMap.push({key: row.AACR_ID__c, value: compMap[row.AACR_ID__c]});
        //     });
        //
        //     cmp.set('v.finalCompMap', newCompMap);
        // }

        
        var action = cmp.get("c.createParticipants");

        action.setParams({
            contacts: cmp.get('v.confirmList'),
            eventId: cmp.get('v.eventId'),
            bypassEmail: cmp.get('v.bypassConfirmEmail'),
            compMapString: JSON.stringify(cmp.get('v.finalCompMap'))
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('CreateRecords SUCCESS!');
                var jobId = response.getReturnValue();
                console.log('jobId = ' + jobId);
                // helper.goBacktoEvent(cmp);
                if(jobId) {
                    cmp.set('v.showConfirm', false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success!',
                        message: 'Batch executed successfully',
                        duration: ' 3000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    helper.executeBatch(cmp, jobId);
                }


            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occurred. Please try again or contact System Administrator."
                });
                toastEvent.fire();

            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "An Error has occurred. Please try again or contact System Administrator."
                });
                toastEvent.fire();
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

    backToEvent : function(cmp,event,helper){
        helper.goBacktoEvent(cmp);
    }

});