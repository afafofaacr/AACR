/**
 * Created by lauren.lezberg on 3/21/2019.
 */
({
    selectRecord : function(component, event, helper){
        console.log('record selected...');
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