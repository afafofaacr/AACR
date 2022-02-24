/**
 * Created by afaf.awad on 9/20/2021.
 */

({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.checkAccess");
        action.setParams({
            "contactId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var access = response.getReturnValue();
                console.log('ticketAccess: ' + JSON.stringify(access));
                cmp.set("v.hasAccess", access);
            } else if (state === "INCOMPLETE") {
                console.log('Could not check access - OS: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not check access - OS - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not check access - OS: Unknown error");
                }

            }
        });
        $A.enqueueAction(action);
    },

    handleSave : function (cmp,event,helper){

        if(helper.validate(cmp)) {
            let action = cmp.get("c.saveSegmentOverride");
            action.setParams({
                "contactId": cmp.get("v.recordId"),
                "wbilReason": cmp.find('wbilReason').get('v.value'),
                "wbil": cmp.find('wbil').get('v.value'),
                "intType": cmp.find('intType').get('v.value'),
                "intTypeReason": cmp.find('intTypeReason').get('v.value'),
                "accountId": cmp.get('v.accountId')
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let data = response.getReturnValue();
                    console.log('data: ' + JSON.stringify(data));
                    cmp.set("v.modalOpen", false);
                } else if (state === "INCOMPLETE") {
                    console.log('Could not save override segment: Incomplete Callout');
                } else if (state === "ERROR") {
                    let errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Could not save override segment - Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Could not save override segment: Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }

    },

    inputChanged : function(cmp,event,helper){
        let fieldName = event.getSource().getLocalId() ;
        console.log('field Changed == ' + fieldName);
        cmp.set('v.'+ fieldName + 'ReasonRequired', true);
    },

    openModal : function(cmp,event, helper){
        cmp.set("v.modalOpen", true);
        helper.getContactSegment(cmp);
    },

    closeModal : function (cmp, event, helper){
        cmp.set("v.modalOpen", false);
    }
});