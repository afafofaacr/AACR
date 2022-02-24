/**
 * Created by lauren.lezberg on 6/17/2020.
 */
({
    doInit : function(cmp, event, helper){
        helper.initialize(cmp, event);
    },

    openModal: function(cmp, event, helper){

        cmp.set("v.modalOpen", true);

        var val = event.getSource().get("v.value");
        console.log("value: " + val);
        if(val!=null){
            cmp.set("v.roleId", val);
            cmp.find('roleForm').set("v.recordId", val);
        }

    },

    confirmDelete : function(cmp, event, helper){
        var roleId = event.getSource().get("v.value");

        var action = cmp.get("c.deleteRole");
        action.setParams({
            "roleId": roleId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if(!data){
                   console.log("error deleting record");
                } else {
                    helper.initialize(cmp, event);
                }

            } else if (state === "INCOMPLETE") {
                // do something

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

    closeModal : function(cmp, event, helper){
        cmp.find('roleForm').set("v.recordId", null);
        cmp.set("v.modalOpen", false);

    },

    handleSuccess : function(cmp, event, helper){
        cmp.find('roleForm').set("v.recordId", null);
        cmp.set("v.modalOpen", false);
        helper.initialize(cmp, event);

    }
})