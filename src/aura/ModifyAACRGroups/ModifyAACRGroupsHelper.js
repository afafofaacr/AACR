/**
 * Created by lauren.lezberg on 4/1/2021.
 */

({
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
        console.log('reustls: ' + results);
        if(results!=null) {

            var SOId = results[1];
            return SOId;
        }

        return null;
    },

    closeOrder : function(cmp){
        console.log('ModifyAACRGroups closeOrder...');


        var selected = cmp.find('workingGroups').get("v.selectedGroups");
        console.log('selections: ' + selected);

        var action = cmp.get("c.completeAACRGroupsOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId"),
            "selectedItems": selected,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(data){
                    window.location = '/MemberProfile';
                } else {
                    //TODO: handle error
                    console.log('update failed');
                }

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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

    cancelOrder : function(cmp){
        var action = cmp.get("c.deleteOrder");
        action.setParams({
            "salesOrderId" : cmp.get("v.salesOrderId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location = '/MemberProfile';
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
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
    }

});