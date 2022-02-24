/**
 * Created by afaf.awad on 9/20/2021.
 */

({
    getContactSegment : function (cmp){
        let action = cmp.get("c.getSegmentInfo");
        action.setParams({
            "contactId": cmp.get("v.recordId")
        })
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));
                cmp.set('v.accountId', data.AccountId);

            } else if (state === "INCOMPLETE") {
                console.log('Could not get Contact segment info: Incomplete Callout');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not get Contact segment info - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get Contact segment info: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },


    validate : function (cmp){
        let isValid = true;

        let reasonValid = fieldName => {
            let reason = cmp.find(fieldName + 'Reason');
            let reasonVal = reason.get("v.value");
            console.log('reason == ' + JSON.stringify(reason));
            console.log('reasonVal == ' + reasonVal);
            if (!reasonVal) {
            $A.util.addClass(reason, 'slds-has-error');
            return false;
        } else {
            $A.util.removeClass(reason, 'slds-has-error');
            return true;
        }
        }


        if(cmp.get('v.intTypeReasonRequired')) {
            isValid = reasonValid('intType');
        }
        if(cmp.get('v.wbilReasonRequired')){
            isValid = reasonValid('wbil');

        }
        return isValid;
    }

});