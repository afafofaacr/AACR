/**
 * Created by lauren.lezberg on 6/29/2020.
 */
({
    doInit : function(cmp, event, helper){
        cmp.set("v.lowercaseOName", cmp.get("v.objectName").toLowerCase());
        var action = cmp.get("c.getFields");
        action.setParams({
            "objectName" : cmp.get("v.objectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('available fields: '+ JSON.stringify(data[0]));
                // console.log('selected fields: '+ JSON.stringify(data[1]));
                // var fields = [];
                // data[0].forEach(function(record){
                //     // console.log('record: ' + JSON.stringify(record));
                //     var aItem = {
                //         "label": record.fieldLabel,
                //         "value": record.fieldName
                //     };
                //     fields.push(aItem);
                // });
                //
                //
                // var selectedFields = [];
                // data[1].forEach(function(record){
                //     var selItem = {
                //         "label": record.fieldLabel,
                //         "value": record.fieldName
                //     };
                //     fields.push(selItem)
                //     selectedFields.push(record.fieldName);
                // });
                cmp.set("v.fieldList", data[0]);
                cmp.set("v.selectedList", data[1]);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not apply discount - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not apply discount: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    removeField : function(cmp,event, helper){
        var selected = event.getSource().get("v.value");
        // console.log('remove selected: ' + selected);

        var fieldList = cmp.get("v.fieldList");
        var selectedList = cmp.get("v.newSelected");

        selectedList.forEach(function(field, index){
            if(field.fieldName == selected){
                // var FVP = {fieldValue:field.fieldName, fieldLabel:field.fieldLabel, fieldType:field.fieldType };
                fieldList.push(field);
                selectedList.splice(index, 1);
            }
        });

        fieldList.sort((a, b) => {
            if (a.label < b.label)
                return -1;
            if (a.label > b.label)
                return 1;
            return 0;
        });

        // console.log('fieldList: ' + fieldList);

        cmp.set("v.fieldList", fieldList);
        cmp.set("v.newSelected", selectedList);
        cmp.set("v.selectedField", null);

    },

    addField: function(cmp, event, helper){
        var selected = cmp.get("v.selectedField");

        var fieldList = cmp.get("v.fieldList");
        var selectedList = cmp.get("v.newSelected");

        fieldList.forEach(function(field, index){
            if(field.fieldName == selected){
                // var FVP = {fieldValue:null, fieldName: field.fieldValue, fieldLabel:field.fieldLabel, operator: null, fieldType:field.fieldType};
                selectedList.push(field);
                fieldList.splice(index, 1);
            }
        });

        cmp.set("v.fieldList", fieldList);
        cmp.set("v.newSelected", selectedList);
        cmp.set("v.selectedField", null);
    },

    selectField : function(cmp, event,helper){
        var selected = event.target.value;
        // console.log('selected: ' + selected);

        cmp.set("v.selectedField", selected);
    },

    saveFields : function(cmp, event, helper){
        console.log('selected: ' + JSON.stringify(cmp.get("v.newSelected")));
        var action = cmp.get("c.saveSegmentFields");
        action.setParams({
            "objectName" : cmp.get("v.objectName"),
            "selectedJSON" : JSON.stringify(cmp.get("v.newSelected"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('success!');
                cmp.set("v.modalOpen", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : 'success',
                    "title": "Success!",
                    "message": "Job has been submitted successfully. The page will refresh in 30 seconds."
                });
                toastEvent.fire();

                setTimeout(function(){ $A.get('e.force:refreshView').fire();}, 3000);

            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not apply discount: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    openModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", true);

    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", false);
    }


})