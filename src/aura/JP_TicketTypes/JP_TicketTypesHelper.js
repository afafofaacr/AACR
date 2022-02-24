/**
 * Created by lauren.lezberg on 11/11/2019.
 */
({
    getEventId : function(cmp, event){
        var name ='c__event';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {
            return results[1];
        }

        return null;
    },


    saveTicketTypes : function(cmp, event, redirect){
        var selectedSegments = cmp.get("v.selectedSegments");

        var hasError = false;
        selectedSegments.forEach(function(segment){
            if(!segment.EB){
                segment.EBPrice = null;
                segment.EBDate = null;
            } else {
                if(segment.EBDate == null){
                    hasError = true;
                }
            }
            if(!segment.OD){
                segment.ODPrice = null;
                segment.ODDate = null;
            } else {
                if(segment.ODDate == null){
                    hasError = true;
                }
            }
        });

        if(!hasError) {
            var action = cmp.get("c.saveEventUserSegments");
            action.setParams({
                "eventId": this.getEventId(cmp, event),
                "ticketTypes": selectedSegments
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();

                    if (redirect == true) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": this.getEventId(cmp, event),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }

                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout: saveEventUserSegments');
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
        } else {
            
            cmp.find('notifLib').showToast({
                "title": "Please make sure all required fields are filled out.",
                "message": event.getParam("message"),
                "variant": "error"
            });
        }
    }
})