/**
 * Created by lauren.lezberg on 7/6/2020.
 */
({
    doInit : function(cmp, event, helper){
        var action = cmp.get("c.getVirtualDetailRecord");
        action.setParams({
           "eventId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var resp = response.getReturnValue();
                console.log('resp: ' + JSON.stringify(resp));
               if(resp!=null) {
                   if(resp.details!=null) {
                       cmp.set("v.detailId", resp.details.Id);
                       cmp.set("v.exhibitOpen", resp.details.Exhibit_Open__c);
                       cmp.set("v.zoomUserId", resp.details.Zoom_User_Id__c);
                       if(cmp.get("v.editable")) {
                           cmp.find("editForm").set("v.recordId", resp.details.Id);
                       }
                   }

                   cmp.set("v.hideDetails", resp.hideDetails);

                   if((resp.zoomUsers!=null && Object.keys(resp.zoomUsers).length!=0)){
                       cmp.set("v.showPassword", true);
                       var zUsers = [];
                       var users = resp.zoomUsers;
                       console.log('users: ' + JSON.stringify(users));
                       for(var key in users){
                           zUsers.push({value:users[key], key: key});
                       }
                       cmp.set("v.zoomUsers", zUsers);
                       if(cmp.find('type')!=null && cmp.find('type')!=undefined) {
                           if (cmp.find('type').get("v.value") == null || cmp.find('type').get("v.value") == undefined) {
                               cmp.find('users').set("v.disabled", true);
                           }
                       }
                   }


               }

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getZone");
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

    handleTypeChange : function(cmp, event, helper){
        var type = event.getSource().get("v.value");

        var action = cmp.get("c.getZoomUsers");
        action.setParams({
            "type" : type
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                var zUsers = [];
                resp.forEach(function(u){
                    zUsers.push({value:u.MasterLabel, key: u.userId__c});
                });
                cmp.set("v.zoomUsers", zUsers);
                if(type=='Webinar'){
                    $A.util.addClass(cmp.find('password'), 'slds-hide');
                } else {
                    $A.util.removeClass(cmp.find('password'), 'slds-hide');
                }
                if(cmp.find('type').get("v.value")!=null && cmp.find('type').get("v.value")!=undefined){
                    cmp.find('users').set("v.disabled", false);
                }

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getZone");
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

    updateZoomAccount : function(cmp, event, helper){
        console.log('updateZoomAccount...');
        var userId = event.getSource().get("v.value");
        console.log(event.getSource().get("v.value"));
        cmp.find('userId').set("v.value", userId);
        cmp.get("v.zoomUsers").forEach(function(u){
            if(u.key == userId){
                cmp.find('zAccount').set("v.value", u.value);
            }
        })
    },

    toggleExhibit : function(cmp, event, helper){
        var action = cmp.get("c.updateExhibit");
        action.setParams({
            "detailEvent" : cmp.get("v.detailId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();

                cmp.set("v.exhibitOpen", resp);

                if(resp) {
                    location.reload();
                }

            } else if (state === "INCOMPLETE") {
                console.log("Incomplete callout: getZone");
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

    saveForm : function(cmp, event, helper){
        if(cmp.get("v.editable")) {
            cmp.find("editForm").submit();
        }
    }
})