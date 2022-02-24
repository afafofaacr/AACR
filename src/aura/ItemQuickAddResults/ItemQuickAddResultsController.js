/**
 * Created by lauren.lezberg on 10/7/2019.
 */
({
    /**
     * Handles record selection and fires oSelectedRecordEvent to notify ItemQuickAdd component
     * @param component
     * @param event
     * @param helper
     */
    selectRecord : function(component, event, helper){
        // get the selected record from list
        var getSelectRecord = component.get("v.oRecord");
        // call the event
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.
        compEvent.setParams({"recordByEvent" : getSelectRecord });
        // fire the event
        compEvent.fire();
    },
})