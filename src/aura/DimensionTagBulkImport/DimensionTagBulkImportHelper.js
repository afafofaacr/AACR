/**
 * Created by afaf.awad on 6/8/2021.
 */

({
    closeModal : function (cmp,event){
        let cmpEvent = cmp.getEvent('callDimTagEvent');
        cmpEvent.setParams({
            'action' : 'destroy'
        })
        cmpEvent.fire();
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
            const delimiter = ',';
            const quotes = '"';
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
            // console.log(file);
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
                var output = file.name + '- last modified: ' + file.lastModifiedDate.toLocaleDateString();
                component.set("v.filename", file.name);
                component.set("v.TargetFileName", output);

            };
            reader.onload = function (e) {
                var data = e.target.result;
                component.set("v.fileContentData", data);
                console.log("file data" + JSON.stringify(data));
                var allTextLines = data.split(/\r\n|\n/);
                // console.log('allTextLines type of = ' + typeof allTextLines);


                var dataRows = allTextLines.length - 1;
                console.log("dataRows" + JSON.stringify(dataRows));

                var headers = allTextLines[0].split(',');

                if (headers) {
                    data = headers;
                    var picklist = [];
                    for (var key in data) {
                        picklist.push({label: data[key], value: data[key]});
                    }
                    component.set("v.tableheaders", picklist);
                }

                var filecontentdataPreview;
                var contentPreview = "<table class=\"table slds-table slds-table--bordered slds-table--cell-buffer\">";
                contentPreview += "<thead><tr class=\"slds-text-title--caps\">";
                for (i = 0; i < headers.length; i++) {
                    contentPreview += '<th scope=\"col"\>' + headers[i] + '</th>';
                }
                var rows = dataRows > 10 ? 11 : allTextLines.length;
                contentPreview += "</tr></thead>";
                for (var i = 1; i < rows; i++) {
                    console.log("allTextLines" + JSON.stringify(allTextLines[i]));
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
                    filecontentdata = splitCSVButIgnoreCommasInDoublequotes(allTextLines[i]);
                    if (filecontentdata != '') {
                        for (var j = 0; j < filecontentdata.length; j++) {
                            content += filecontentdata[j];
                        }
                    }
                }

                component.set("v.TableContent", contentPreview);
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
            idField: component.get('v.idField'),

        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('Return validateFile = ' + data);
                if(data.validated){
                    console.log('ready to process');
                    component.set('v.processing', false);
                    component.set('v.showConfirm', true);
                    component.set('v.showPreview', false);
                    component.set('v.idList', data.recordIds);
                }else {
                    component.set('v.processing', false);
                    this.callErrorMsg(component, "Looks like you pick a column that does not have valid Salesforce Ids. Please review your file.");
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

    downloadCSV: function (cmp, results) {
        // get the data to export to csv
        let stockData = results;

        console.log('downloadCSV...stockData = ' + JSON.stringify(stockData));

        // call the helper function which "return" the CSV data as a String
        let csv = this.convertArrayOfObjectsToCSV(cmp,stockData);
        if (csv == null){
            return;}

        // console.log('csvConvertArrayhelper = ' + csv);
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = 'Tag_Record_Results.csv';  // CSV file Name
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();
    },

    convertArrayOfObjectsToCSV : function(component,objectRecords){
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }

        let csvStringResult, counter, keys, columnDivider, lineDivider;
        columnDivider = ',';
        lineDivider = '\n';
        keys = ['recordId','tagId', 'message'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;

        for (let i = 0; i < objectRecords.length; i++) {
            counter = 0;

            for (let sTempkey in keys) {
                let skey = keys[sTempkey];
                if (counter > 0) {
                    csvStringResult += columnDivider;
                }
                if (objectRecords[i][skey] != null) {
                    csvStringResult += '"' + objectRecords[i][skey] + '"';
                } else {
                    csvStringResult += '"' + '' + '"';
                }
                counter++;
            }
            csvStringResult += lineDivider;
        }
        return csvStringResult;
    },
});