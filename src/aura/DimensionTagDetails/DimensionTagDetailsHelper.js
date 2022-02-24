/**
 * Created by afaf.awad on 6/8/2021.
 */

({
    buildColumns: function (cmp, objectName, convertedTags) {
        // console.log('Building columns...');
        let columns = [
            {label: 'Delete Requested', fieldName: 'isDeleted', type:'button-icon', initialWidth: 175, sortable: true, actions: this.getDeleteHeaderActions(cmp),
                typeAttributes: { label: {fieldName: 'deleteIcon'}, iconName: {fieldName: "deleteIcon"}, variant: 'bare'},
                cellAttributes:{class: "slds-align_absolute-center"}},
            {label: 'Tag', fieldName: 'link', type: 'button', sortable: true, typeAttributes: {label: {fieldName: 'tagName'}, variant: 'base'}},
            // {label: 'Delete Requested',fieldName: 'isDeleted',type: 'Boolean', sortable: true, actions: this.getDeleteHeaderActions(cmp)}
            ];

        if (objectName == 'Contact') {
            columns.push({
                label: 'Converted From',
                fieldName: 'cLink',
                type: 'button',
                sortable: true,
                typeAttributes: {label: {fieldName: 'cnvtTag'}, variant: 'base'},
                actions: this.getConvertedHeaderActions(cmp, convertedTags)
            });
        }

        if (objectName == 'Lead') {
            columns.push({
                label: 'Converted To',
                fieldName: 'cLink',
                type: 'button',
                sortable: true,
                typeAttributes: {label: {fieldName: 'cnvtTag'}, variant: 'base'},
                actions: this.getConvertedHeaderActions(cmp, convertedTags)
            });
        }

        // console.log('columns == ' + JSON.stringify(columns));

        return columns;
    },

    getDeleteHeaderActions : function(cmp){
        // console.log('building header actions...');
        return [
            {
                label: 'All Flags',
                checked: true,
                name:'All'
            },
            {
                label: 'Show Flags',
                checked: false,
                name:'showFlags'
            },
            {
                label: 'Hide Flags',
                checked: false,
                name:'hideFlags'
            },
        ];
    },


    getConvertedHeaderActions : function(cmp, tags){
        // console.log('building header actions...');
        let headerActions = [{
            label: 'None',
            checked: false,
            name: 'None'
            },
            {
                label: 'All',
                checked: true,
                name: 'All'
            }];

        tags.forEach(item => {
            headerActions.push({
                label: item,
                checked: false,
                name: item
            });
        });

        return headerActions;
    },

    getDetails : function(cmp, dimTagId){
        let pageSize = cmp.get("v.pageSize").toString();
        let pageNumber = cmp.get("v.pageNumber").toString();
        // console.log('pagenumber == ' + pageNumber + ' and pagesize == ' + pageSize);


        let action = cmp.get("c.getDimTagDetails");
        action.setParams({
            dimTagId : dimTagId,
            pageSize : pageSize,
            pageNumber : pageNumber
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                let convertTags =[];
                if(data.unionTags.length !== 0) {
                    console.log('returned response == ' + JSON.stringify(data));
                    data.unionTags.forEach(function (row) {
                        row.tagName = row.dtRecord.Object_Lookup__r.Name;  //.length > 70 ? row.Object_Lookup__r.Name.substring(0,50) + '...': row.Object_Lookup__r.Name;
                        row.link = row.dtRecord.Object_Lookup__r.Id;
                        row.isDeleted = row.dtRecord.Request_for_Removal__c;
                        row.deleteIcon = row.isDeleted ? 'utility:lower_flag' : 'utility:record';
                        if(row.convertedTag){
                            row.cnvtTag = row.convertedTag.Label;
                            row.cLink = '/' + row.convertedTag.Id ;
                            convertTags.push(row.convertedTag.Label);
                        }
                    });
                }


                cmp.set('v.columns', this.buildColumns(cmp, data.dimTag.Object__c ,convertTags));
                cmp.set("v.dataSize", data.unionTags.length);
                cmp.set("v.isLastPage", data.unionTags.length < cmp.get("v.pageSize") ? true : false);
                cmp.set('v.detailsData', data.unionTags);
                cmp.set('v.detailsDataDefault', data.unionTags);
                cmp.set('v.DimTag', data.dimTag);
                cmp.set('v.isLoading', false);
                // cmp.set('v.totalNumberOfRows', data.dtRecords.length);
                console.log('DimTag == ' + JSON.stringify(cmp.get('v.DimTag')));

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
                cmp.set('v.isLoading', false);
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - doInit DimTag Details: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: doInit");
                }
                cmp.set('v.isLoading', false);
            }
        });
        $A.enqueueAction(action);
    },

    getDetailsToExport : function(cmp, idListString, type){
        let exportType = type == 'marketExport' ? 'market' : 'full';
        let dimTag = cmp.get('v.DimTag');
        let action = cmp.get("c.exportTags");
        action.setParams({
            objectName: dimTag.Object__c,
            // idListString : idListString,
            exportType : exportType,
            dimTagId : cmp.get('v.dimTagId')

        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('data = ' + JSON.stringify(data));
                this.downloadCSV(cmp, data, dimTag, type);

                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Data Exported!',
                    message: dimTag.Object__c + ' details for these tags are downloaded.',
                    duration: ' 3000',
                    key: 'success',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                cmp.set('v.processing', false);

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

    downloadCSV: function (cmp, results, dimTag, type) {
        // get the data to export to csv
        const dateTime = (new Date()).toISOString().slice(0, 16).replace(":", "").replace("T", " ").replace(" ","_");
        let stockData = results.objectList;
        let exportType = type == 'marketExport' ? 'ME' : 'FE';
        let username = results.user.Username.substring(0, results.user.Username.lastIndexOf("@"));

        console.log('downloadCSV...stockData = ' + JSON.stringify(stockData));

        // call the helper function which "return" the CSV data as a String
        let csv = this.convertArrayOfObjectsToCSV(cmp,stockData,results.headers);
        if (csv == null){return;}

        let filename = 'DTM-' + exportType + '_' + dimTag.Object__c + '_' + dimTag.Label.replace(' ','_') + '-'+ username +'-' + dateTime +'.csv';  // CSV file Name

        // console.log('csvConvertArrayhelper = ' + csv);
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; //
        hiddenElement.download = filename;
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click();

        this.recordDownload(cmp,filename,dimTag.Object__c,dimTag.Label,results.user.Id, exportType);
    },

    convertArrayOfObjectsToCSV : function(component,objectRecords, headers){
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }

        let csvStringResult, counter, keys, columnDivider, lineDivider, row;
        columnDivider = ',';
        lineDivider = '\n';
        keys = headers;
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;

        for (let i = 0; i < objectRecords.length; i++) {
            counter = 0;
            row =[]; //put each row into a new array
            for (let sTempkey in keys) {
                let skey = keys[sTempkey];

                if (objectRecords[i][skey] != null) {
                    row.push(objectRecords[i][skey]);
                } else {
                    row.push('');
                }

                // if (counter > 0) {
                //     csvStringResult += columnDivider;
                // }
                // if (objectRecords[i][skey] != null) {
                //     csvStringResult += '"' + objectRecords[i][skey] + '"';
                // } else {
                //     csvStringResult += '"' + '' + '"';
                // }

                counter++;
            }
            csvStringResult += row.join(columnDivider); //join array into comma delimited string.
            csvStringResult += lineDivider;
        }
        return csvStringResult;
    },

    recordDownload:function (cmp, filename, object, tagLabel, userId, type){
        let action = cmp.get("c.logDownload");
        action.setParams({
            objectName: object,
            tagLabel : tagLabel,
            filename : filename,
            userId : userId,
            exportType : type
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('log saved!');
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - doInit');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - recordDownload: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: recordDownload");
                }
            }
        });
        $A.enqueueAction(action);
    },

    sortData: function (cmp, fieldName, sortDirection) {
        let data = cmp.get("v.detailsData");
        let reverse = sortDirection !== 'asc';
        fieldName = fieldName == 'link' ? 'tagName' : fieldName;
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.detailsData", data);
    },

    sortBy: function (field, reverse, primer) {
        let key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    filterData : function (cmp, flag, tagFilter){
        console.log('flag == ' + flag + ' and tagFilter == ' + tagFilter);

        let cTag = ct => {
            // console.log('tagFilter == ' + tagFilter);
            if (tagFilter == 'All'){
                return ct;
            }else if(ct.convertedTag) {
                if (ct.convertedTag.Label == tagFilter) {
                    return ct;
                }
            }else if (tagFilter == 'None') {
                    return ct;
            }
        }


        let tagList = tags => {
            let newTagList =[];
            tags.forEach((tag) => {
                // console.log('tag == ' + JSON.stringify(tag));
                if(flag == 'All') {
                    newTagList.push(cTag(tag));
                }else if (flag == 'showFlags' && tag.isDeleted){
                    newTagList.push(cTag(tag));
                }else if (flag == 'hideFlags' && !tag.isDeleted){
                    newTagList.push(cTag(tag));
                }
            });

            return newTagList;

            }

            let newList = tagList(cmp.get('v.detailsDataDefault '));
            newList = newList.filter(item => item);
            // console.log('newList == ' + JSON.stringify(newList));
            cmp.set('v.detailsData', newList);
    }
});