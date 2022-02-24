/**
 * Created by afaf.awad on 5/27/2021.
 */

({
    handleRemove: function(cmp,event,helper){
        console.log('removing pill...');
        event.preventDefault();
        let target = event.getSource().get('v.name');
        let action = cmp.get("c.removeTagRecord");
        action.setParams({
            'tagRecordId' : target,
            'recordId' : cmp.get('v.recordId'),
            'tagLevel' : cmp.get('v.tagLevel')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('success!!');
                let cmpEvent = cmp.getEvent('callDimTagEvent');
                cmpEvent.fire();

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - handleRemove: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - handleRemove: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: handleRemove");
                }
            }
        });
        $A.enqueueAction(action);
    },

    goToReport : function(cmp,event,helper){
        let target = event.getSource().get('v.name');
        console.log('target Name == ' + target);
        let action = cmp.get("c.getReportURL");
        action.setParams({
            'dimTagId' : target,
            'objectName' : cmp.get('v.sobjecttype')
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let url = response.getReturnValue();
                window.open(url,'_blank');
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: - goToReport: ');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - goToReport: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: goToReport");
                }
            }
        });
        $A.enqueueAction(action);
    }
});