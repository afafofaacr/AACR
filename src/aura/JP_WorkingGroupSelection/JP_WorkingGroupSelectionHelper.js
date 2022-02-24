/**
 * Created by lauren.lezberg on 1/23/2019.
 */
({
    /**
     * @purpose Calls apex method to retrieve all available working groups
     * @param cmp
     * @param event
     */
    initialize : function(cmp, event){
        console.log('JP_WorkingGroupSelection initialize...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getWorkingGroupData");
        action.setParams({
            "salesOrderId" : this.getSalesOrderId(cmp),
            "stepId" : cmp.get("v.stepId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.workingGroups", data);
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

    /**
     * @purpose Calls apex method that saves all selected working groups as sales order lines. Upon success, user is navigated forward or backward in join.
     * Upon failure, user is not redirected and receives a javascript error.
     * @param cmp
     * @param event
     * @param selected
     * @param stepId
     * @param cmpName
     */
    saveSelections : function(cmp, event, selected, stepId, cmpName){
        console.log('JP_WorkingGroupSelection saveSelections...');

        console.log('selected: ' + JSON.stringify(selected));
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.saveWorkingGroupSelections");
        action.setParams({
            "salesOrderId": this.getSalesOrderId(cmp),
            "selectedItems": selected,
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data.isSuccess) {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId" : stepId});
                    navEvt.setParams({"cmpName" : cmpName});
                    navEvt.fire();
                } else {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId" : cmp.get("v.stepId")});
                    navEvt.setParams({"cmpName" : null});
                    navEvt.fire();

                    alert('Error saving data: ' + data.message);
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

    /**
     * @purpose Retrieves sales order id parameter from URL
     * @param cmp
     * @returns {string}
     */
    getSalesOrderId : function(cmp){
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        var SOId=results[1];
        return SOId;
    },

})