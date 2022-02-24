/**
 * Created by afaf.awad on 6/5/2020.
 */

({
    /**
     * @purpose Retrieve join process id parameter from page URL
     * @param cmp
     * @returns {*}
     */
    getEventId : function(cmp){
        var name ='c__eventId';
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

    validateSelection : function(cmp,event,selectedRows){

        this.callErrorMsg(cmp,'');
        // var selectedRows = event.getParam('selectedRows');
        var sorted_arr = selectedRows.slice().sort();
        var validated = true;

        for (var i = 0; i < sorted_arr.length - 1; i++) {
            if (sorted_arr[i + 1].Email === sorted_arr[i].Email) {
                console.log('dups detected');
                this.callErrorMsg(cmp,"You've selected duplicate contacts. Please review your selections.");
                validated = false;
            }
        }
        return validated;

    },

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

                //TODO: limit file size to 50000 records.

                // var numOfRows=component.get("v.NumOfRecords");
                // if(dataRows > 50000){
                //
                //     alert("File is too large. Only allowed 50000 rows .");
                //     component.set("v.showFile",false);
                //
                // }
                // else{
                var lines = [];
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

                // } ---Commented out Else bracket
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
            emailField: component.get('v.emailField'),

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
                    this.callErrorMsg(component, "An email is missing in the file, this is a required entry. Please review your file making sure email is populated for every Contact.");
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
        //set up columns for Contact Table
        component.set('v.contactColumns', [
            {label: 'Name', fieldName: 'link', type: 'url',
                typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'AACR ID', fieldName: 'AACR_ID__c', type: 'text'},
            {label: 'Email', fieldName: 'Email', type: 'Email'},
            {label: 'Record Type', fieldName: 'recordType', type: 'text'},
            {label: 'Member Type', fieldName: 'Member_Type__c', type: 'text'},
            {label: 'Member Status', fieldName: 'Membership_Status__c', type: 'text'}
        ]);

        //set up columns for Attendee Table
        component.set('v.attendeeColumns', [
            {label: 'Contact', fieldName: 'link', type: 'url',
                typeAttributes: {label: { fieldName: 'EventApi__Full_Name__c' }, target: '_blank'}},
            {label: 'Registration Date', fieldName: 'EventApi__Registration_Date__c', type: 'date-local'},
            {label: 'Email', fieldName: 'EventApi__Email__c', type: 'Email'},
        ]);

        console.log('fileData: ' + component.get("v.fileContentData"));
        var action = component.get("c.processData");
        action.setParams({
            fileData: component.get("v.fileContentData"),
            fields: fieldList,
            aacrField: component.get('v.aacrField'),
            emailField: component.get('v.emailField'),
            eventId : component.get('v.eventId')

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('response = ' + JSON.stringify(response.getReturnValue()));
                var data = response.getReturnValue();
                if(JSON.stringify(data.duplicateContacts) == "[]" && JSON.stringify(data.emailDoesNotExist) == "[]" && JSON.stringify(data.attendees) == "[]"){
                    this.getListofContactstoCreate(component, data.aacrIDs);
                    component.set('v.processing', false);
                }else {
                    var dups = data.duplicateContacts;
                    dups.forEach(function (row) {
                        //to show the record type name
                        row.recordType = row.RecordType.Name;
                        row.link = '/' + row.Id;
                    });

                    var mis = data.mismatchedContacts;
                    mis.forEach(function (row) {
                        //to show the record type name
                        row.recordType = row.RecordType.Name;
                        row.link = '/' + row.Id;
                    });

                    var attendeeList = data.attendees;
                    attendeeList.forEach(function (row) {
                        //to show the record type name
                        row.link = '/' + row.Id;
                    });

                    component.set("v.dupContacts", dups);
                    // console.log('dupContants = ' + dups);
                    component.set("v.attendees", attendeeList);
                    // console.log('attendees = ' + attendeeList);
                    component.set("v.missingContacts", data.emailDoesNotExist);
                    // console.log('missingContacts = ' + data.emailDoesNotExist);
                    component.set("v.aacrIdList", data.aacrIDs);
                    component.set('v.mismatchedContacts', data.mismatchedContacts);
                    // console.log('mismatchedContacts = ' + data.mismatchedContacts);
                    component.set("v.showPreview", false);
                    component.set("v.showValidation", true);
                    component.set('v.processing', false);
                }

            } else if (state === "INCOMPLETE") {
                // do something
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

    getListofContactstoCreate : function (cmp,conList){
        cmp.set('v.processing', true);
        var action = cmp.get("c.queryContactsByAACRID");

        action.setParams({
            aacrIds: conList,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('response = ' + JSON.stringify(response.getReturnValue()));
                var data = response.getReturnValue();
                data.forEach(function(row){
                    //to show the record type name
                    row.recordType = row.RecordType.Name;
                    row.link = '/' + row.Id;
                });
                cmp.set("v.confirmList", data);
                cmp.set("v.showConfirm", true);
                cmp.set("v.showValidation", false);
                cmp.set("v.showPreview", false);
                cmp.set('v.processing', false);

            } else if (state === "INCOMPLETE") {
                console.log('State is INCOMPLETE');
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

    downloadCSV: function (cmp) {
        // get the data to export to csv
        let stockData = cmp.get("v.missingContacts");

        console.log('downloadCSV...missingContacts = ' + stockData);

        // call the helper function which "return" the CSV data as a String
        let csv = this.convertArrayOfObjectsToCSV(cmp,stockData);
        if (csv == null){
            return;}

        console.log('csvConvertArrayhelper = ' + csv);
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'Mass_Registration_Missing_Contacts.csv';  // CSV file Name
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();
    },

    convertArrayOfObjectsToCSV : function(component,objectRecords){
        let csvStringResult, counter, lineDivider;
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }

        lineDivider =  '\n';
        csvStringResult = '';
        csvStringResult += ['Email'];
        csvStringResult += lineDivider;

        for(let i=0; i < objectRecords.length; i++){
            counter = 0;
                if(objectRecords[i] != null){
                    csvStringResult += '"'+ objectRecords[i]+'"';
                }else{
                    csvStringResult += '"'+ '' +'"';
                }
                counter++;
            csvStringResult += lineDivider;
        }

        return csvStringResult;
    },

    goBacktoEvent : function (cmp){
        var navLink = cmp.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'EventApi__Event__c',
                recordId : cmp.get('v.eventId')
            },
        };
        navLink.navigate(pageRef, true);
    }
});