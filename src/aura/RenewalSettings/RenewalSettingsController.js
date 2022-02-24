/**
 * Created by lauren.lezberg on 9/6/2019.
 */
({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getRenewalData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' , data);
                cmp.set("v.processSetting", data.renewalSettings);
                // cmp.set("v.duesItems", data.duesItems);
            }
            else if (state === "INCOMPLETE") {
                // do something
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

    // updateDuesItem : function(cmp, event, helper){
    //    var itemId = event.getSource().get("v.value");
    //    console.log('itemId: ' + itemId);
    //    var itemToUpdate = {};
    //    cmp.get("v.duesItems").forEach(function(item){
    //        if(itemId == item.Id){
    //            itemToUpdate = item;
    //        }
    //    });
    //     var action = cmp.get("c.saveDuesItem");
    //     action.setParams({
    //         "record" : itemToUpdate
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var data = response.getReturnValue();
    //             $A.get('e.force:refreshView').fire();
    //         }
    //         else if (state === "INCOMPLETE") {
    //             // do something
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " +
    //                         errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },

    updateRenewalSetting : function(cmp, event, helper){
        helper.saveRenewalSetting(cmp, event);
    },

    toggleRenewalActivation : function(cmp, event, helper){
        console.log('toggleRenewals...');
        var setting = cmp.get("v.processSetting");
        if(setting.Is_Active__c){
            setting.Is_Active__c = false;
        } else {
            setting.Is_Active__c = true;
        }
        cmp.set("v.processSetting", setting);
        helper.saveRenewalSetting(cmp, event);
    }
})