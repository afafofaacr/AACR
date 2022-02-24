/**
 * Created by afaf.awad on 3/5/2021.
 */

({
    doInit : function (cmp,event,helper){
        console.log('doInit...');

        let orderId;
        let name ='c__orderId';
        let url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        let regexS = "[\\?&]"+name+"=([^&#]*)";
        let regex = new RegExp( regexS, "i" );
        let results = regex.exec( url );
        if(results!=null){
            orderId = results[1];
        }
        let action = cmp.get("c.approveBudget");
        action.setParams({
            "orderId" : orderId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let results = response.getReturnValue();
                if (results) {
                    console.log('success!');
                    }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
                let errors = response.getError();
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