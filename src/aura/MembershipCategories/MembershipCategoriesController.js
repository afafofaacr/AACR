/**
 * Created by lauren.lezberg on 12/11/2018.
 */
({

    doInit: function(cmp,event, helper) {
        console.log('MembershipCategories init...');


        var action = cmp.get("c.getMembershipItems");
        action.setParams({
            "isTransfer": helper.getIsTransfer()
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.items", data);
            }
            else if (state === "INCOMPLETE") {
                // do something
                console.log('incomplete callout');
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
        });
        $A.enqueueAction(action);
    },

    goToJoinProcess : function(cmp, event, helper){
        console.log('MembershipCategories goToJoinProcess...');

        cmp.set("v.isLoading", true);
        var itemId = event.getSource().get('v.value');
        if(helper.getIsTransfer()){
            helper.newTransferApplication(cmp, itemId);
        } else {
            helper.newMemberApplication(cmp, itemId);
        }
    }


})