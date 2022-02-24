/**
 * Created by afaf.awad on 9/29/2021.
 */

({
    getSurveyId : function(cmp){
        var name ='c__survey';
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

    sortFields: function (fieldList) {
        function compare(a, b) {
            // Use toUpperCase() to ignore character casing
            const fieldA = a.Default_Order__c ? a.Default_Order__c : a.Label.toUpperCase();
            const fieldB = b.Default_Order__c ? b.Default_Order__c : b.Label.toUpperCase();

            let comparison = 0;
            if (fieldA > fieldB) {
                comparison = 1;
            } else if (fieldA < fieldB) {
                comparison = -1;
            }
            return comparison;
        }

        // console.log('FieldList pre sort == ' + JSON.stringify(fieldList) );

        fieldList.sort(compare);
        fieldList = this.setFieldTypes(fieldList);
        // console.log('FieldList post sort == ' + JSON.stringify(fieldList) );

        fieldList.forEach(f => f.dragId = f.Id); //add dragId to each sorted list.
        // console.log('fieldList == ' + JSON.stringify(fieldList));
        return fieldList
    },

    orderSavedFields: function (cmp) {
        // console.log('SavedFields ==== ' + JSON.stringify(fieldList));
        function compare(a, b) {
            // Use toUpperCase() to ignore character casing
            const fieldA = a.sqRecord.OrderNumber__c;
            const fieldB = b.sqRecord.OrderNumber__c;

            let comparison = 0;
            if (fieldA > fieldB) {
                comparison = 1;
            } else if (fieldA < fieldB) {
                comparison = -1;
            }
            return comparison;
        }
        let fieldList = cmp.get('v.bodyDropFields');
        fieldList.sort(compare);
        // console.log('FieldList post sort == ' + JSON.stringify(fieldList) );
        cmp.set('v.bodyDropFields', fieldList);
    },

    setFieldTypes : function(fieldList){
        fieldList.forEach(f => {
            f.Field_Type__c = f.Field_Type__c.replace('mtd_','');
        });
        return fieldList;
    },

    setUpLockedFields : function (cmp){

        let filterLockedFields = (fieldList, dropList) => {
            let lockedFields = fieldList.filter(field => field.isLocked__c == true); //pull locked fields into new array
            let newFieldList = fieldList.filter(field => field.isLocked__c == false); //filter out locked fields, keep only unlocked fields
            lockedFields.forEach(field => {
                field.dragId = field.Id;
                dropList.push(field)
            }); //add locked fields to droplist.

            return {newFieldList, dropList};
        }

        let lockedBody = filterLockedFields(cmp.get('v.PerInfoFields'), cmp.get('v.bodyDropFields'));
        let lockedFooter = filterLockedFields(cmp.get('v.FooterFields'), cmp.get('v.footerDropFields'));

        // console.log('bodyDropFields == ' + JSON.stringify(lockedBody.dropList));
        // console.log('footerDropFields == ' + JSON.stringify(lockedFooter.dropList));

        cmp.set('v.PerInfoFields', lockedBody.newFieldList);
        cmp.set('v.bodyDropFields', lockedBody.dropList);
        cmp.set('v.FooterFields', lockedFooter.newFieldList);
        cmp.set('v.footerDropFields', lockedFooter.dropList);
    },

    setUpLayout : function (cmp,sqMetadataMap, sqRecordMap, fieldFormList,dropZoneList){

        let fieldList = cmp.get(fieldFormList); //get section fieldlist
        let fieldListCopy = JSON.parse(JSON.stringify(fieldList)); // make a copy of list to keep an original copy. fieldList will be changing.
        let dropList = cmp.get(dropZoneList); //get dropzone list
        // console.log('fieldList for '+ fieldFormList + ' = ' + JSON.stringify(fieldList));
        // console.log('sqRecordMap for '+ fieldFormList + ' = ' + JSON.stringify(sqRecordMap));

        //Loop through metadata fields to find matching fields from sqRecordMap
        let filterOutFields =[];
        Object.keys(sqRecordMap).forEach((key) => {
            let dropFieldFind = fieldListCopy.find(f => f.Id == sqRecordMap[key].MetaTypeId__c);
            let dropField = JSON.stringify(dropFieldFind) ? JSON.parse(JSON.stringify(dropFieldFind)) : undefined;
            // console.log('dropField == ' + JSON.stringify(dropField));
            if(dropField) {
                if (dropField.isUnique__c) {
                    filterOutFields.push(dropField);
                }
                // console.log('dropfield == ' + JSON.stringify( sqRecordMap[key]));
                dropField.sqId = key; //add new element to fieldList object
                dropField.sqRecord = sqRecordMap[key];
                dropField.dragId = dropField.Id + key;
                dropList.push(dropField);
            }
            // console.log('fieldList before filter == ' + JSON.stringify(fieldList));
        });

        // console.log('filterOutFields before filter == ' + JSON.stringify(filterOutFields));


        //filter out any field with an sqId and is a unique field
        fieldList = fieldList.filter(fl => !filterOutFields.find( el => el.Id == fl.Id) );
        fieldList.forEach(f => { f.dragId = f.Id});

        // console.log('fieldList after filter == ' + JSON.stringify(fieldList));
        // console.log('droplist after filter == ' + JSON.stringify(dropList));
        //reset lists
        cmp.set(fieldFormList, fieldList);
        cmp.set(dropZoneList, dropList);
    },


    saveRecord: function(cmp, fieldsList){
        // console.log('saving record...' + JSON.stringify(fieldsList));
        let action = cmp.get("c.saveSurveyQuestions");
        action.setParams({
            fieldListJSON: JSON.stringify(fieldsList).replace('__c',''),
            surveyId : cmp.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('SQ Data Saved');
                this.handleSuccess(cmp);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: WF_FormInfo');
                this.handleError(cmp);
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - Save Form Fields: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in saving Form Fields");
                }
                this.handleError(cmp);
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    handleSuccess: function (cmp) {
        console.log('handleSuccess...');
        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();

    },

    handleError: function (cmp) {
        console.log('handle error');
        // var errors = event.getParams();
        // console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.nextStepId");
        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

});