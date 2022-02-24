/**
 * Created by lauren.lezberg on 2/6/2019.
 */
({
    /**
     * @purpose Creates error toast message 
     * @param cmp
     * @param event
     * @param message
     */
    createErrorToast : function(cmp, event, message){
        console.log('ROERenew createErrorToast...');

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type": "error"
        });
        toastEvent.fire(); 
    }, 


})