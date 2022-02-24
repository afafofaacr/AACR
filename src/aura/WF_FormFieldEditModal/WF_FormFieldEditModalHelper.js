/**
 * Created by afaf.awad on 10/11/2021.
 */

({

    closeModal : function(cmp, field){
        console.log('closing modal...');
        //call parent (FFDropLayout) and update droplist on form field layout to reflect changes made from modal
        let appEvent = $A.get("e.c:WF_AppEvent");
        appEvent.setParams({
            'field' : field
        });
        appEvent.fire();
        cmp.destroy();
    },


    getPicklistValues : function(cmp, fieldName){
        console.log('getting picklist values...' + fieldName);
        let action = cmp.get("c.getPicklistOptions");
        action.setParams({
            "fieldApi": fieldName,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('data = ' + JSON.stringify(data));
                let options = '';
                data.forEach(c => {
                    options += c + '\n';
                })

                cmp.find('qResponses').set('v.value', options);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: setImageToPublic');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    setFileAccessSettings: function(cmp, fileId){
        let action = cmp.get("c.setImageToPublic");
        action.setParams({
            "fileId": fileId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('file set to public..');
                let docId = response.getReturnValue();

                let fieldDetails = cmp.get('v.fieldDetails');
                fieldDetails.imageId = docId;
                cmp.set('v.fieldDetails', fieldDetails);
                cmp.set("v.imageId", docId);

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: setImageToPublic');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +  errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
});