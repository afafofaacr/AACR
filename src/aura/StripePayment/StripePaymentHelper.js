/**
 * Created by lauren.lezberg on 11/18/2020.
 */

({

    getSalesOrderId : function(cmp){
        //get sales order id from URL
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId;
        if(results==null){
            name ='c__salesOrder';
            name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
            name = name.toLowerCase();
            regexS = "[\\?&]"+name+"=([^&#]*)";
            regex = new RegExp( regexS, "i" );
            results = regex.exec( url );
            SOId=results[1];
        } else {
            SOId=results[1];
        }

        return SOId;
    },

    processSOPayment : function(cmp, token){
        var action = cmp.get("c.ProcessPayment");
        action.setParams({
            "token": token,
            "salesOrderId" : this.getSalesOrderId(cmp)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                if(data.success){
                    cmp.set("v.success", true);
                    cmp.set("v.errorMsg", null);
                } else{
                    cmp.set("v.errorMsg", data.errorMsg);
                }
            } else if (state === "INCOMPLETE") {
                // do something
                console.log('incomplete...');
            } else if (state === "ERROR") {
                console.log('error...');
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
    }
});