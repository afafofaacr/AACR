/**
 * Created by lauren.lezberg on 11/2/2020.
 */

({
    // getParticipantId : function(cmp, event, helper){
    //     var action = cmp.get("c.getParticipantFromSO");
    //     action.setParams({
    //         "salesOrderId": cmp.get("v.salesOrderId")
    //     })
    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var resp = response.getReturnValue();
    //             cmp.set("v.participantId", resp);
    //
    //         } else if (state === "INCOMPLETE") {
    //             console.log('Incomplete Callout:doInit');
    //         } else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " +
    //                         errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    validateInput : function(cmp, event, helper){
        var isValid = true;

        if(cmp.get("v.showFileUpload")) {
            if (cmp.find('fileUpload').get("v.fileId") == null || cmp.find('fileUpload').get("v.fileId") == undefined) {
                cmp.set("v.isValid", false);
                isValid = false;
            } else {
                cmp.set("v.isValid", true);
            }
        } else {
            cmp.set("v.isValid", true);
        }

        return isValid;
    },

    handleLoad : function(cmp, event, helper){
        helper.setCheckboxInfo(cmp, event);
    },

    handleCheckboxChange : function(cmp, event, helper){
        helper.setCheckboxInfo(cmp, event);
    }
});