/**
 * Created by afaf.awad on 1/20/2021.
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
                // console.log('dups detected');
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

        function splitCSVButIgnoreCommasInDoublequotes(str) {
            //split the str first
            //then merge the elments between two double quotes
            var delimiter = ',';
            var quotes = '"';
            var elements = str.split(delimiter);
            var newElements = [];
            for (var i = 0; i < elements.length; ++i) {
                if (elements[i].indexOf(quotes) >= 0) {//the left double quotes is found
                    var indexOfRightQuotes = -1;
                    var tmp = elements[i];
                    //find the right double quotes
                    for (var j = i + 1; j < elements.length; ++j) {
                        if (elements[j].indexOf(quotes) >= 0) {
                            indexOfRightQuotes = j;
                            break;
                        }
                    }
                    //found the right double quotes
                    //merge all the elements between double quotes
                    if (-1 != indexOfRightQuotes) {
                        for (var j = i + 1; j <= indexOfRightQuotes; ++j) {
                            tmp = tmp + delimiter + elements[j];
                        }
                        newElements.push(tmp);
                        i = indexOfRightQuotes;
                    }
                    else { //right double quotes is not found
                        newElements.push(elements[i]);
                    }
                }
                else {//no left double quotes is found
                    newElements.push(elements[i]);
                }
            }

            return newElements;
        }

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
                // console.log('allTextLines type of = ' + typeof allTextLines);
                // console.log("allTextLines" + JSON.stringify(allTextLines));

                var dataRows = allTextLines.length - 1;
                // console.log("dataRows" + JSON.stringify(dataRows));

                var headers = allTextLines[0].split(',');

                if (headers) {
                    data = headers;
                    var picklist = [];
                    for (var key in data) {
                        picklist.push({label: data[key], value: data[key]});
                    }
                    component.set("v.tableheaders", picklist);
                }

                //limit file size to 50000 records.

                // var numOfRows=component.get("v.NumOfRecords");
                // if(dataRows > 50000){
                //
                //     alert("File is too large. Only allowed 50000 rows .");
                //     component.set("v.showFile",false);
                //
                // }
                // else{
                var lines = [];
                var filecontentdataPreview;
                var contentPreview = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                contentPreview += "<thead><tr class=\"slds-text-title--caps\">";
                for (i = 0; i < headers.length; i++) {
                    contentPreview += '<th scope=\"col"\>' + headers[i] + '</th>';
                }
                var rows = dataRows > 10 ? 11 : allTextLines.length;
                contentPreview += "</tr></thead>";
                for (var i = 1; i < rows; i++) {
                    // console.log('allTextLines' + [i] + ' = ' + allTextLines[i]);
                    filecontentdataPreview = splitCSVButIgnoreCommasInDoublequotes(allTextLines[i]);
                    if (filecontentdataPreview != '') {
                        contentPreview += "<tr>";
                        for (var j = 0; j < filecontentdataPreview.length; j++) {
                            contentPreview += '<td>' + filecontentdataPreview[j] + '</td>';
                        }
                        contentPreview += "</tr>";
                    }
                }
                contentPreview += "</table>";


                var filecontentdata;
                var content ;
                for (i = 0; i < headers.length; i++) {
                    content += headers[i];
                }
                var rows = allTextLines.length;
                for (var i = 1; i < rows; i++) {
                    // console.log('allTextLines' + [i] + ' = ' + allTextLines[i]);
                    filecontentdata = splitCSVButIgnoreCommasInDoublequotes(allTextLines[i]);
                    if (filecontentdata != '') {
                        for (var j = 0; j < filecontentdata.length; j++) {
                            content += filecontentdata[j];
                        }
                    }
                }

                // console.log('FINAL filecontentData == ' + content);

                // component.set("v.fileContentData", filecontentdata);
                component.set("v.TableContent", contentPreview);
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
            fileData: JSON.stringify(component.get("v.fileContentData")),
            fields: fieldList,
            // aacrField: component.get('v.aacrField'),
            emailField: component.get('v.emailField'),

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var validated = response.getReturnValue();
                // console.log('Return validateFile = ' + validated);
                if(validated){
                    this.processRecords(component, event, fieldList);
                }else {
                    component.set('v.processing', false);
                    this.callErrorMsg(component, "Looks like you pick a column that does not have valid emails. Please review your file making sure email is populated for every Contact.");
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
                typeAttributes: {label: { fieldName: 'contactName' }, target: '_blank'}},
            {label: 'Registration Date', fieldName: 'regDate', type: 'date-local'},
            {label: 'Email', fieldName: 'contactEmail', type: 'Email'},
        ]);

        //set up columns for Invalid Comp Code Table
        // component.set('v.invalidCodesColumn', [
        //     {label: 'Email', fieldName: 'Email'},
        //     {label: 'COMP Code', fieldName: 'Code'},
        // ]);

        // console.log('fileData: ' + component.get("v.fileContentData"));

        var action = component.get("c.processData");
        action.setParams({
            fileData: component.get("v.fileContentData"),
            fields: fieldList,
            // compCodeField: component.get('v.compCode'),
            emailField: component.get('v.emailField'),
            eventId : component.get('v.eventId')

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('response = ' + JSON.stringify(response.getReturnValue()));
                var data = response.getReturnValue();
                if(JSON.stringify(data.duplicateContactsList) == "[]" && JSON.stringify(data.emailDoesNotExist) == "[]" &&
                    JSON.stringify(data.participations) == "[]" && JSON.stringify(data.contactsNoUser) == "[]"){
                    // && JSON.stringify(data.emailInvalidCode) == "[]"){
                    // component.set('v.idCompMap', data.compMap);
                    component.set('v.dupContactMap', data.duplicateContactsMap)

                    this.getListofContactstoCreate(component, data.aacrIDs);
                    component.set('v.processing', false);
                }else {
                        var dups = data.duplicateContactsList;
                        // console.log('create duplicate list...' + dups);
                        dups.forEach(function (row) {
                            //to show the record type name
                            row.recordType = row.RecordType.Name;
                            row.link = '/' + row.Id;
                        });

                        var attendeeList = data.participations;
                        // console.log('create participants list...' + attendeeList);
                        attendeeList.forEach(function (row) {
                            //to show the record type name
                            row.link = '/' + row.partId;
                            row.contactName = row.Contact__r.FirstName + ' ' + row.Contact__r.LastName;
                            row.regDate = row.Registration_Date__c;
                            row.contactEmail = row.Contact__r.Email;
                        });

                        var noUser = data.contactsNoUser;
                        // console.log('create contacts with no user list...' + JSON.stringify(noUser));
                        noUser.forEach(function (row) {
                            //to show the record type name
                            row.link = '/' + row.Id;
                            row.recordType = row.RecordType.Name;
                        });

                    component.set("v.dupContacts", dups);
                    component.set("v.attendees", attendeeList);
                    component.set("v.missingContacts", data.emailDoesNotExist);
                    component.set("v.aacrIdList", data.aacrIDs);
                    component.set("v.contactsNoUser", noUser);
                    // component.set('v.mismatchedContacts', data.mismatchedContacts);
                    component.set("v.showPreview", false);
                    component.set("v.showValidation", true);
                    component.set('v.processing', false);
                    // component.set('v.idCompMap', data.compMap);
                    component.set('v.dupContactMap', data.duplicateContactsMap);
                    // component.set('v.invalidCodes', data.emailInvalidCode);
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

        // console.log('downloadCSV...missingContacts = ' + stockData);

        // call the helper function which "return" the CSV data as a String
        let csv = this.convertArrayOfObjectsToCSV(cmp,stockData);
        if (csv == null){
            return;}

        // console.log('csvConvertArrayhelper = ' + csv);
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'MassReg_Missing_Contacts.csv';  // CSV file Name
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


    downloadCSV_NoUsers: function (cmp) {
        // get the data to export to csv
        let stockData = cmp.get("v.contactsNoUser");

        // call the helper function which "return" the CSV data as a String
        let csv = this.convertArrayOfObjectsToCSV_noUser(cmp,stockData);
        if (csv == null){
            return;}

        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'MassReg_Contacts_without_PortalUsers.csv';  // CSV file Name
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();
    },

    convertArrayOfObjectsToCSV_noUser : function(component,objectRecords){
        let csvStringResult, counter, keys, columnDivider, lineDivider;

        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and
        // for start next line use '\n' [new line] in lineDivider varaible
        columnDivider = ',';
        lineDivider =  '\n';

        // in the keys variable, store fields API Names as a key
        // this labels use in CSV file header
        keys = ['Name','AACR_ID__c','Email','recordType','Member_Type__c','Membership_Status__c'];

        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;

        for(let i=0; i < objectRecords.length; i++){
            counter = 0;

            for(let sTempkey in keys) {
                let skey = keys[sTempkey] ;

                // add , [comma] after every String value,. [except first]
                if(counter > 0){
                    csvStringResult += columnDivider;
                }

                if(objectRecords[i][skey] != null){

                    csvStringResult += '"'+ objectRecords[i][skey]+'"';

                }else{
                    csvStringResult += '"'+ '' +'"';
                }
                counter++;

            } // inner for loop close
            csvStringResult += lineDivider;
        }// outer main for loop close

        // return the CSV formatted String
        return csvStringResult;

    },

    downloadCSV_NoCodes: function (cmp) {
        // get the data to export to csv
        let stockData = cmp.get("v.invalidCodes");

        // call the helper function which "return" the CSV data as a String
        let csv = this.convertArrayOfObjectsToCSV_noCodes(cmp,stockData);
        if (csv == null){
            return;}

        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'MassReg_Contacts_InvalidCodes.csv';  // CSV file Name
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();
    },

    convertArrayOfObjectsToCSV_noCodes: function (component, objectRecords) {
        let csvStringResult, counter, keys, columnDivider, lineDivider;

        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        // store ,[comma] in columnDivider variabel for sparate CSV values and
        // for start next line use '\n' [new line] in lineDivider varaible
        columnDivider = ',';
        lineDivider = '\n';


        // in the keys variable, store fields API Names as a key
        // this labels use in CSV file header
        keys = ['Email', 'Code'];

        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;


        for (let i = 0; i < objectRecords.length; i++) {
            counter = 0;

            for (let sTempkey in keys) {
                let skey = keys[sTempkey];

                // add , [comma] after every String value,. [except first]
                if (counter > 0) {
                    csvStringResult += columnDivider;
                }

                if (objectRecords[i][skey] != null) {

                    csvStringResult += '"' + objectRecords[i][skey] + '"';

                } else {
                    csvStringResult += '"' + '' + '"';
                }
                counter++;

            } // inner for loop close
            csvStringResult += lineDivider;
        }// outer main for loop close

        // return the CSV formatted String
        return csvStringResult;
    },

    goBacktoEvent: function (cmp) {
        var navLink = cmp.find("navLink");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'BR_Event__c',
                recordId: cmp.get('v.eventId')
            },
        };
        navLink.navigate(pageRef, true);
    },

    executeBatch: function (cmp, jobId) {
        console.log('executing batch...');
        setInterval($A.getCallback(function () {
            var jobStatus = cmp.get("c.getMassReg_BatchJobStatus");
            if (jobStatus != null) {
                jobStatus.setParams({
                    jobId: jobId
                });
                jobStatus.setCallback(this, function (jobStatusResponse) {
                    var state = jobStatus.getState();
                    if (state === "SUCCESS") {
                        var job = jobStatusResponse.getReturnValue();
                        cmp.set('v.apexJob', job);
                        console.log('apexjob = ' + JSON.stringify(job));
                        var processedPercent = 0;
                        if (job.JobItemsProcessed != 0) {
                            processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                        }else{
                            processedPercent = 100;
                        }
                        cmp.set('v.progress', processedPercent);
                    }
                });
                $A.enqueueAction(jobStatus);
            }
        }), 1000);
    },

});