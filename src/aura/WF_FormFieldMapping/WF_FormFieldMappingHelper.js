/**
 * Created by afaf.awad on 10/20/2021.
 */

({
    getSurveyId : function(cmp){
        var name ='c__survey';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },

    saveRecord: function(cmp, sqList){
        console.log('saving record...');
        let action = cmp.get("c.saveFieldMapping");
        action.setParams({
            sqRecordsJSON: JSON.stringify(sqList),
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('SQ Data Saved');
                this.handleSuccess(cmp);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: WF_FormFieldMapping');
                this.handleError(cmp);
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - WF_FormFieldMapping: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in WF_FormFieldMapping");
                }
                this.handleError(cmp);
            }
            cmp.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    handleSuccess: function (cmp) {
        console.log('handleSuccess...');
        var stepId = cmp.get("v.nextStepId");
        var cmpName = cmp.get("v.nextCmpName");

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": cmpName});
        navEvt.fire();

    },

    handleError: function (cmp) {
        console.log('handle error');
        // var errors = event.getParams();
        // console.log("Error Response", JSON.stringify(errors));

        var stepId = cmp.get("v.nextStepId");
        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": stepId});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

});