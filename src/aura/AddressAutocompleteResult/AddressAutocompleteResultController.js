/**
 * Created by lauren.lezberg on 9/8/2020.
 */

({
    selectRecord : function(cmp, event, helper){
        // get the selected record from list
        var getSelectRecord = cmp.get("v.oRecord");
        // call the event
        var compEvent = cmp.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.
        compEvent.setParams({"recordByEvent" : getSelectRecord });
        // fire the event
        compEvent.fire();
    },
});