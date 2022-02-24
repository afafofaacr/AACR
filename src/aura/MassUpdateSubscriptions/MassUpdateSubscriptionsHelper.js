/**
 * Created by afaf.awad on 12/8/2020.
 */

({
    callErrorMsg : function(cmp, message){
        var cmpEvent = $A.get("e.c:ComponentError");
        cmpEvent.setParams({
            "errorMsg" : message });
        cmpEvent.fire();
    },

    readFile: function (component, helper, file) {
        if (!file) return;
        // console.log('file' + file.name);
        if (!file.name.match(/\.(csv||CSV)$/)) {
            return alert('This file is not a CSV. Only CSV files are supported.');
        } else {

            reader = new FileReader();
            reader.onerror = function errorHandler(evt) {
                switch (evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                        alert('An error occurred reading this file.');
                }
                ;
            }
            //reader.onprogress = updateProgress;
            reader.onabort = function (e) {
                alert('File read cancelled');
            };
            reader.onloadstart = function (e) {
                // var output = '<ui type=\"disc\"><li><strong>' + file.name + '</strong> - last modified: ' + file.lastModifiedDate.toLocaleDateString() + '</li></ui>';

                var output = '<strong>' + file.name + '</strong> - last modified: ' + file.lastModifiedDate.toLocaleDateString();
                component.set("v.filename", file.name);
                component.set("v.TargetFileName", output);

            };
            reader.onload = function (e) {
                var data = e.target.result;
                component.set("v.fileContentData", data);
                // console.log("file data" + JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                var dataRows = allTextLines.length - 1;
                var headers = allTextLines[0].split(',');

                if (headers) {
                    data = headers;
                    var picklist = [];
                    for (var key in data) {
                        picklist.push({label: data[key], value: data[key]});
                    }
                    component.set("v.tableheaders", picklist);
                }

                var filecontentdata;
                var content = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                content += "<thead><tr class=\"slds-text-title--caps\">";
                for (i = 0; i < headers.length; i++) {
                    content += '<th scope=\"col"\>' + headers[i] + '</th>';
                }
                var rows = dataRows > 10 ? 11 : allTextLines.length;
                content += "</tr></thead>";
                for (var i = 1; i < rows; i++) {
                    filecontentdata = allTextLines[i].split(',');
                    // console.log('filecontectdata= ' + filecontentdata);
                    if (filecontentdata != '') {
                        content += "<tr>";
                        for (var j = 0; j < filecontentdata.length; j++) {
                            content += '<td>' + filecontentdata[j] + '</td>';
                        }
                        content += "</tr>";
                    }
                }
                content += "</table>";

                component.set("v.TableContent", content);
                component.set("v.showFile", false);
                component.set("v.showPreview", true);
            }
            reader.readAsText(file);

        }
        var reader = new FileReader();
        reader.onloadend = function () {

        };
        reader.readAsDataURL(file);
    },

    validateFile: function(component,event, fieldList){
        console.log('validating file...');
        var action = component.get("c.validateData");
        action.setParams({
            fileData: component.get("v.fileContentData"),
            fields: fieldList,
            aacrField: component.get('v.aacrField'),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var validated = response.getReturnValue();
                console.log('Return validateFile = ' + validated);
                if(validated){
                    this.processRecords(component, event, fieldList);
                }else {
                    component.set('v.processing', false);
                    this.callErrorMsg(component, "The required field, AACR ID, is missing in this file. Please review your file making sure an AACR ID is populated for every Contact.");
                }
            } else if (state === "INCOMPLETE") {
                component.set('v.processing', false);
            } else if (state === "ERROR") {
                component.set('v.processing', false);
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

    processRecords: function (component, event, fieldList) {

        console.log('fileData: ' + component.get("v.fileContentData"));
        var action = component.get("c.processData");
        action.setParams({
            fileData: component.get("v.fileContentData"),
            fields: fieldList,
            aacrField: component.get('v.aacrField'),
            isRenew: component.get('v.isRenew')

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var jobId = response.getReturnValue();
                if (jobId) {
                    var message = component.get('v.isRenew') == true ? 'Membership Renewal' : 'Suspend Prior Members';
                    this.callToast(component,'success', 'Success!', message + " batch process successfully initiated." );
                this.getBatchJobStatus(component,jobId);
            }else {
                    this.callToast(component,"error","Error!","An Error has occurred. Please contact System Administrator.");
                }
            } else if (state === "INCOMPLETE") {
                this.callToast(component,"error","Error!","An Error has occurred. Please contact System Administrator.")
                component.set('v.processing', false);
            } else if (state === "ERROR") {
                component.set('v.processing', false);
                this.callToast(component,"error","Error!","An Error has occurred. Please contact System Administrator.")
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

    getBatchJobStatus : function(cmp, batchId){
            var interval = setInterval($A.getCallback(function () {
                var jobStatus = cmp.get("c.getBatchJobStatus");
                if (jobStatus != null) {
                    jobStatus.setParams({
                        jobId: batchId
                    });
                    jobStatus.setCallback(this, function (jobStatusResponse) {
                        var state = jobStatus.getState();
                        if (state === "SUCCESS") {
                            var job = jobStatusResponse.getReturnValue();
                            cmp.set("v.showPreview", false);
                            cmp.set('v.apexJob', job);
                            var processedPercent = 0;
                            if(job.Status == 'Completed' && job.JobItemsProcessed == 0 ){
                                processedPercent = 100;
                            }else if (job.JobItemsProcessed != 0) {
                                processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                            }
                            var progress = cmp.get('v.progress');
                            // cmp.set('v.progress', progress === 100 ? clearInterval(interval) : processedPercent);
                            cmp.set('v.progress', processedPercent);
                        }
                    });
                    $A.enqueueAction(jobStatus);
                }
            }), 2000);

    },

    callToast : function(cmp,type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }

});