/**
 * Created by lauren.lezberg on 6/24/2020.
 */
({
    handleCancel : function(cmp, event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

    handleSuccess : function(cmp,event, helper){
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})