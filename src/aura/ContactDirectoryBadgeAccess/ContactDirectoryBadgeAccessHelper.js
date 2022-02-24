/**
 * Created by lauren.lezberg on 5/3/2019.
 */
({
    getBadgeInfo : function(cmp, event){
        var action = cmp.get("c.getDirectoryAccessBadge");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var badgeInfo = response.getReturnValue();
                console.log(badgeInfo);
                if(badgeInfo.dirBadge!=null) {
                    cmp.set("v.badge", badgeInfo.dirBadge);
                    if (badgeInfo.dirBadge.OrderApi__Is_Active__c) {
                        cmp.set("v.radioValue", 'enable');
                    } else {
                        cmp.set("v.radioValue", 'revoke');
                    }

                }
                cmp.set("v.canEdit", badgeInfo.canEdit);
            }

            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.errorMsg", 'An error occurred while retrieving badge info. Please contact your salesforce administrator.');
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
    }
})