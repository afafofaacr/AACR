/**
 * Created by lauren.lezberg on 1/13/2021.
 */

({


    getInfo : function(cmp, event, helper){
        // console.log('salesOrderId: ' + cmp.set("v.salesOrderId"));
        var action = cmp.get("c.getGDPRInfo");
        action.setParams({
            "salesOrderId": cmp.get("v.salesOrderId")
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log("resp: " + JSON.stringify(resp));
                cmp.set("v.participantId", resp);

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

    handleChange : function(cmp, event, helper){
        console.log("val: " + event.getSource().get("v.value"));
        console.log('val1: ' + cmp.find('consent').get("v.value"));
        cmp.find('gdprForm').submit();
    }
});