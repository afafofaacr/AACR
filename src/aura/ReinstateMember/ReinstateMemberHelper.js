/**
 * Created by lauren.lezberg on 2/6/2020.
 */
({
    /**
     * @purpose Creates error message toast
     * @param cmp
     * @param event
     * @param message
     */
    createErrorToast : function(cmp, event, message){
        console.log('ReinstateMember createErrorToast...');

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire();
    },
})