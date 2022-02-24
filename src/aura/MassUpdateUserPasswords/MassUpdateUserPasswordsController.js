/**
 * Created by afaf.awad on 7/13/2021.
 */

({
    openWizard : function(cmp,event,helper){
        let cmpName = event.getSource().getLocalId();
        cmp.set("v.actionCmp", []);

        $A.createComponent(
            "c:MassUpdateUserPasswordWizard",
            {},
            function (actionCmp, status, errorMessage) {
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var cmpInput = cmp.get("v.actionCmp");
                    cmpInput.push(actionCmp);
                    cmp.set("v.actionCmp", cmpInput);
                } else if (status === "INCOMPLETE") {
                    console.log("Could not create component: No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Could not create component: Error - " + errorMessage);
                }
            });
    },

    closeWizard :function(cmp,event,helper){
        let batchId = event.getParam('batchId');
        cmp.set("v.actionCmp", []);
        if(batchId) {
            helper.getBatchJobStatus(cmp, batchId);
        }
    }
});