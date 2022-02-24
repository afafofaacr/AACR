/**
 * Created by lauren.lezberg on 1/24/2019.
 */
({
    initialize : function(cmp, event){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getOptionalItemData");
        action.setParams({
            "salesOrderId" : this.getSalesOrderId(cmp),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.items", data);
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            }
            else if (state === "ERROR") {
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

            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },


    saveSelections : function(cmp, event, selected, stepId, cmpName){
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.saveOptionalItemSelections");
        action.setParams({
            "salesOrderId": this.getSalesOrderId(cmp),
            "selectedItems": selected,
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('response: ', data);
                if (data.isSuccess) {
                    // window.location.href = cmp.get("v.nextStepURL");
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId" : stepId});
                    navEvt.setParams({"cmpName" : cmpName});
                    navEvt.fire();
                } else {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId" : cmp.get("v.stepId")});
                    navEvt.setParams({"cmpName" : null});
                    navEvt.fire();
                    alert('Could not save data: ' + data.message);
                }

            } else if (state === "INCOMPLETE") {
                cmp.set("v.isLoading", false);
                console.log('Incomplete Callout');
            } else if (state === "ERROR") {
                cmp.set("v.isLoading", false);
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
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId=results[1];
        console.log(SOId);
        return SOId;
    },

    getStepId : function(){
        var name ='id';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null){
            var stepId=results[1];
            console.log(stepId);
            return stepId;
        }
        return null;
    }
})