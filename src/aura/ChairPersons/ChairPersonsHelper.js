/**
 * Created by lauren.lezberg on 1/14/2020.
 */
({

    getInitialData : function(cmp, event){
        var action = cmp.get("c.getChairPersonsData");
        action.setParams({
            "eventId": cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));
                cmp.set("v.persons", data.persons);
                cmp.set("v.recordTypeId", data.cpRecordTypeId);

                cmp.set("v.newModalOpen", false);

                const rand=()=>Math.random(0).toString(36).substr(2);
                const token=(length)=>(rand()+rand()+rand()+rand()).substr(0,length);

                cmp.set("v.cmpId", token(40)); 
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: getInitialData');

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - getInitialData: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error:getInitialData");
                }
            }
        });
        $A.enqueueAction(action);
    },

    deleteSelectedChair: function(cmp,event){
        // console.log("deleting selected chair: " + cmp.get("v.selectedId"));

        var action = cmp.get("c.deleteChairperson");
        action.setParams({
            "cpId": cmp.get("v.selectedId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.selectedId", null);

                this.getInitialData(cmp, event);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout: deleteSelectedChair');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - deleteSelectedChair: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error: deleteSelectedChair");
                }
            }
        });
        $A.enqueueAction(action);
    },
})