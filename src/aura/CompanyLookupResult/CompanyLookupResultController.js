/**
 * Created by afaf.awad on 7/29/2020.
 */

({
    selectRecord : function(component, event, helper){
        // get the selected record from list
        var getSelectRecord = component.get("v.oRecord");
        // call the event
        console.log("selectRecord==" + JSON.stringify(getSelectRecord));
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.
        compEvent.setParams({"recordByEvent" : getSelectRecord });
        // fire the event
        compEvent.fire();
    },

    callHelp : function (cmp, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
                window.open(baseURL + '/myAACRHelp', '_blank');

    }

});