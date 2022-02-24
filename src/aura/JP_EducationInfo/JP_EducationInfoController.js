/**
 * Created by lauren.lezberg on 1/28/2019.
 */
({

    doInit: function (cmp, event, helper) {
        console.log('JP_EducationInfo init...');

        // Prepare a new record from template
        cmp.set("v.isLoading", true);
        helper.createNewRecord(cmp, event);
        var action = cmp.get("c.getEducationData");
        action.setParams({
            "stepId": cmp.get("v.stepId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var records = [];
                data.educations.forEach(function (record) {
                    records.push(helper.createRecordWrapper(record));
                });
                cmp.set("v.educationRecords", records);
                cmp.set("v.contactId", data.contactId);
                cmp.set("v.academicStatus", data.statusList);
                cmp.set("v.degreeTypes", data.degrees);
                cmp.set("v.isLoading", false);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
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
                cmp.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    },


    goToTransfer: function (cmp, event, helper) {
        console.log('JP_EducationInfo goToTransfer...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.deferAndTransfer");
        action.setParams({
            "salesOrderId": helper.getSalesOrderId(cmp)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = '/MembershipCategories?isTransfer=true'
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
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
                cmp.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);

    },

    handleContactLoad : function(cmp, event){
        console.log('JP_EducationInfo handleContactLoad...');

        if(cmp.find('appStatus').get("v.value")=='Deferred'){
            cmp.set("v.ineligible", true);
            cmp.set("v.recordError", 'You are not eligible to recertify for this membership and cannot continue this application.\n' +
                'You may cancel below and return to your profile or click transfer to find the right membership.');
        }
    },

    handleSaveEntry: function (cmp, event, helper) {
        console.log('JP_EducationInfo handleSaveEntry...');

        cmp.set("v.simpleRecord.Education_Related_to_Contact__c", cmp.get("v.contactId"));

        if (helper.validateRecord(cmp, event)) {
            cmp.set("v.isLoading", true);
            cmp.find("recordEditor").saveRecord(function (saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // record is saved successfully
                    cmp.set("v.isLoading", false);
                    var record = cmp.get("v.simpleRecord");
                    var records = cmp.get("v.educationRecords");
                    if (cmp.get("v.recordId") == null) {
                        records.push(helper.createRecordWrapper(record));
                    } else {
                        records.forEach(function (rec, index) {
                            if (rec.Id == cmp.get("v.recordId")) {
                                records[index] = helper.createRecordWrapper(record);
                            }
                        });
                    }
                    cmp.set("v.educationRecords", records);

                    var form = cmp.find("entryForm");
                    form.set("v.title", '');

                    var border = cmp.find("border");
                    $A.util.removeClass(border, 'emptyError');

                    //null out recordId and record from save
                    cmp.set("v.recordId", null);
                    cmp.set("v.simpleRecord", null);

                    //create new record
                    helper.createNewRecord(cmp, event);

                } else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                    cmp.set("v.isLoading", false);
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving contact, error: ' +
                        JSON.stringify(saveResult.error));
                    cmp.set("v.isLoading", false);
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state +
                        ', error: ' + JSON.stringify(saveResult.error));
                    cmp.set("v.isLoading", false);
                }
            });
        }
    },

    editRecord: function (cmp, event, helper) {
        console.log('JP_EducationInfo editRecord...');

        cmp.set("v.recordId", event.currentTarget.value);
        cmp.find("recordEditor").reloadRecord();

    },

    deleteEducationRecord: function (cmp, event, helper) {
        console.log('JP_EducationInfo deleteEducationRecord...');
        // cmp.set("v.isLoading", true);
        var deleteId = event.currentTarget.value;
        var recordToDelete;
        var records = cmp.get("v.educationRecords");
        records.forEach(function (record, index) {
            if (record.Id == deleteId) {
                recordToDelete = record;
                records.splice(index, 1);
            }
        });
        cmp.set("v.educationRecords", records);
        helper.deleteRecord(cmp, event, recordToDelete);

    },

    handleSave: function (cmp, event, helper) {
        console.log('JP_EducationInfo handleSave...');

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        if(!cmp.get("v.ineligible")) {
            cmp.find('currentStatus').submit();
            if (helper.validateForm(cmp, event)) {

                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": stepId});
                navEvt.setParams({"cmpName": cmpName});
                navEvt.fire();

            } else {
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": cmp.get("v.stepId")});
                navEvt.setParams({"cmpName": null});
                navEvt.fire();
            }
        } else {
            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }
    },

    goNext: function (cmp, event, helper) {
        console.log('JP_EducationInfo goNext...');

        var records = cmp.get("v.educationRecords");
        if (records.length > 0) {
            window.location.href = cmp.get("v.nextStepURL");
        } else {
            var form = cmp.find("entryForm");
            form.set("v.title", 'You must enter at least one education record');

            var border = cmp.find("border");
            $A.util.addClass(border, 'emptyError');
        }
    },

    goPrevious: function (cmp, event, helper) {
        console.log('JP_EducationInfo goPrevious...');

        window.location.href = cmp.get("v.previousStepURL");
    },

    cancelJoin: function (cmp, event, helper) {
        console.log('JP_EducationInfo cancelJoin...');

        window.location.href = cmp.get("v.cancelURL");
    },


})