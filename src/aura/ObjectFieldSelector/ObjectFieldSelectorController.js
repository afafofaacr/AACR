/**
 * Created by lauren.lezberg on 4/1/2020.
 */
({
    doInit : function(cmp, event, helper){
        // console.log("segmentID: " + cmp.get("v.segmentId"));
        var action = cmp.get("c.getFields");
        action.setParams({
            "objectName" : cmp.get("v.objectName"),
            "segmentId" : cmp.get("v.segmentId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('available fields: '+ JSON.stringify(data[0]));
                // console.log('selected fields: '+ JSON.stringify(data[1]));
                var fields = [];
                data[0].forEach(function(record){
                    // console.log('record: ' + JSON.stringify(record));
                    fields.push(record);
                });
                fields.sort((a, b) => {
                    if (a.fieldLabel < b.fieldLabel)
                        return -1;
                    if (a.fieldLabel > b.fieldLabel)
                        return 1;
                    return 0;
                });
                cmp.set("v.fieldList", fields);
                var selectedFields = [];
                data[1].forEach(function(record){
                    selectedFields.push(record);
                });
                cmp.set("v.selectedList", selectedFields);
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
        var selectedList = cmp.get("v.selectedList");

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
        cmp.set("v.selectedList", selectedList);
        cmp.set("v.selectedField", null);

    },

    addField : function(cmp, event, helper){
        var selected = cmp.get("v.selectedField");

        var fieldList = cmp.get("v.fieldList");
        var selectedList = cmp.get("v.selectedList");

        fieldList.forEach(function(field, index){
            if(field.fieldName == selected){
                // var FVP = {fieldValue:null, fieldName: field.fieldValue, fieldLabel:field.fieldLabel, operator: null, fieldType:field.fieldType};
                selectedList.push(field);
                fieldList.splice(index, 1);
            }
        });

        cmp.set("v.fieldList", fieldList);
        cmp.set("v.selectedList", selectedList);
        cmp.set("v.selectedField", null);


    },

    dragStart : function(cmp, event, helper){
      var element = event.target.value;
      // console.log('element: ' + element);
    },

    getFieldValuePairs: function(cmp, event, helper){
        var selectedList = cmp.get("v.selectedList");
        selectedList.forEach(function(selected){
           // console.log("sel: " + JSON.stringify(selected));
        });

        // console.log('selectedList: ' + JSON.stringify(selectedList));

    },


    selectField : function(cmp, event, helper){
        var selected = event.target.value;
        // console.log('selected: ' + selected);

        cmp.set("v.selectedField", selected);




        // $A.util.addClass(selectedCmp, 'selectedField');

        // document.getElementById(selected).classList.add('selectedField');
    }
})