/**
 * Created by lauren.lezberg on 9/14/2020.
 */

({
    handleSuccess : function(cmp, event, helper){
        console.log('handleSuccess...');
        $A.get("e.force:closeQuickAction").fire();
    },


    handleError : function(cmp, event, helper){
        console.log('handleError...');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "message": "Unable to mark bad address.",
            "type" : "error"
        });

        toastEvent.fire();
    }
});