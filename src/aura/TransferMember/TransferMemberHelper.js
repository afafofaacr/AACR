/**
 * Created by lauren.lezberg on 11/15/2019.
 */
({

    /**
     * @purpose Creates error message toast
     * @param cmp
     * @param event
     * @param message
     */
    createErrorToast : function(cmp, event, message){
        console.log('TransferMember createErrorToast...');

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },

})