/**
 * Created by afaf.awad on 12/8/2020.
 */

({
doInit: function (cmp, event, helper) {

    console.log('Creating MassUpdateSubscriptionsCmp');

    },

    reInit: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
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
        var valid = false;
        if (component.get('v.showFile')) {
            var inputCmp = component.find("fileInput");
            var value = inputCmp.get("v.value");
            if (!value) {
                inputCmp.reportValidity();
            }
        } else {
            var fieldCmp = component.find('fieldToMap');
            var field = fieldCmp.get('v.value');
            if(!field) {
                fieldCmp.reportValidity();
            }else{
                valid = true;
            }

            // if (allValid) {
                // var fieldList = [];
                // fieldList.push(component.get('v.aacrField'));
                // fieldList.push(component.get('v.emailField'));
                // for (var i = 0; i < fieldList.length - 1; i++) {
                //     if (fieldList[i + 1] === fieldList[i]) {
                //         allValid = false;
                //         helper.callErrorMsg(component, "You've choosen the same columns. Please review you field choices.");
                //     }
                // }
                if (valid) {
                    var tableheaders = component.get("v.tableheaders");
                    var headerArray = tableheaders.values();
                    var fieldList = [];
                    for (var value of headerArray) {
                        fieldList.push(value.value);
                    }
                    component.set('v.processing', true);
                    helper.validateFile(component,event,fieldList);

                }
            // }
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

});