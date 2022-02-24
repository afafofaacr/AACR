/**
 * Created by lauren.lezberg on 2/12/2021.
 */

({

    createParticipant : function(cmp, stepId, cmpName){
        // console.log('createParticipant...');
        // console.log('contactId: ' + cmp.get("v.contactId"));
        // console.log('salesOrderId: ' + cmp.get("v.salesOrderId"));
        // console.log('eventId: ' + cmp.get("v.eventId"));
        var action = cmp.get("c.addCareerFairTicket");
        action.setParams({
            "contactId" : cmp.get("v.contactId"),
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "careerFairEventId": cmp.get("v.eventId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": stepId});
                navEvt.setParams({"cmpName": cmpName});
                navEvt.fire();
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:doInit');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    removeCareerFairSOLine: function(cmp){
        var action = cmp.get("c.removeCareerFairTicket");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "careerFairEventId": cmp.get("v.eventId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('line removed');
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:doInit');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    getSalesOrderId : function(cmp){
        var name ='salesOrder';
        var url = location.href;
        if(url.indexOf('%26')!=-1) {
            url = url.replace('%26', '&');
        }
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1];
        }

        return null;
    },

    getChildEventId : function(cmp){
        var name ='childEventId';
        var url = location.href;
        if(url.indexOf('%26')!=-1) {
            url = url.replace('%26', '&');
        }
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1];
        }

        return null;
    }
});