/**
 * Created by lauren.lezberg on 4/3/2020.
 */
({
    doInit : function(cmp, event, helper){
      console.log('doInit...');
      console.log('eventId: ' + cmp.get("v.eventId"));
        var action = cmp.get("c.getVirtualEventLinks");
        action.setParams({
            "eventId" : cmp.get("v.eventId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + JSON.stringify(data));
                if(data!=null) {
                    cmp.set("v.computerCheckLink", data.Computer_Check_Link__c);
                    cmp.set("v.viewLink", data.View_Link__c);
                    cmp.set("v.eventIsActive", data.Event_IsActive__c);
                    cmp.set("v.checkIsActive", data.Check_IsActive__c);
                    cmp.set("v.registrationOpen", data.Registration_Open__c);
                    cmp.set("v.isCME", data.isCME__c);
                    cmp.set("v.cmeLink", data.CME_Link__c);
                }
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not get event links: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not cancel order - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not get event links: Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    goToEvent : function(cmp, event, helper){
        var redirectUrl = event.getSource().get("v.value");

        if(redirectUrl.includes('&regId=')) {
            redirectUrl = redirectUrl + cmp.get("v.contactId");
        }

        window.open(redirectUrl, '_blank');
    },


    redirect : function(cmp, event, helper){
        var redirectUrl = event.getSource().get("v.value");

        // var urlEvent = $A.get("e.force:navigateToURL");
        // urlEvent.setParams({
        //     "url": redirectUrl
        // });
        // urlEvent.fire();

        // window.location.href = redirectUrl;

        window.open(redirectUrl, '_blank');
    },


    downloadPDF : function (cmp,event, helper) {

        var attendeeId = cmp.get('v.attendeeId');

        console.log('AttendeeId = ' + attendeeId);

            var action = cmp.get('c.getLetterToDownload');
            action.setParams({
                "attendeeId": attendeeId
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var url = response.getReturnValue();
                    console.log('response: ' + url);
                    window.open(url, '_blank');
                } else if (state === "INCOMPLETE") {
                    console.log('Could not get response: Incomplete Callout');
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Could not get response - Error message: " +
                                errors[0].message);
                        }
                    } else {
                        console.log("Could not get response: Unknown error");
                    }
                }
            });

            $A.enqueueAction(action);

        }

})