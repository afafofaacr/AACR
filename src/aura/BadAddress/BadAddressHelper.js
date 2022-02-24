/**
 * Created by afaf.awad on 11/2/2020.
 */

({
    validation : function(cmp){

        var isValid = [];
        let addresses = cmp.get('v.knownAddress');
        addresses.forEach(function(row){
            console.log('knownAddress == ' + JSON.stringify(row));
            if(row.isBadAddress){
                if(row.rtsReason == ''){
                    console.log('reason is null : ' + row.OrderApi__Street__c);
                    isValid.push(false);
                }else if(row.rtsReason == 'Other (please enter into Other Return)'){
                    if(row.rtsReasonOther == ''){
                        console.log('reason is null : ' + row.OrderApi__Street__c);
                        isValid.push(false);
                    }
                }
            }
        });

        console.log('IsValid == ' + isValid);

        if(isValid.length > 0) {
            cmp.set('v.error', true);
            cmp.set('v.errorMessage', 'Complete the required fields.');
            return false;
        }else{
            return true;
        }

    },


    saveRecords : function(cmp, audit, kaIds){
        console.log('calling server...');
        var action = cmp.get("c.saveBadAddress");
        action.setParams({
            // "contactString": JSON.stringify(contact),
            "auditString" : audit,
            "kaIdString" : JSON.stringify(kaIds)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()) {
                    cmp.set('v.processing', false);
                    console.log('Success saving Contact...');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "success",
                        "title": "Success!",
                        "message": "This record has been updated successfully."
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }else{
                    console.log('response: ' + response.getReturnValue());
                    this.callErrorToast(cmp);
                }

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                this.callErrorToast(cmp);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                        this.callErrorToast(cmp);
                    }
                } else {
                    console.log("Unknown error");
                    this.callErrorToast(cmp);
                }
            }

        });
        $A.enqueueAction(action);
    },

    callErrorToast : function (cmp){
            cmp.set('v.processing', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Error:",
                "message": "There was an error saving this record."
            });
            toastEvent.fire();
    }
});