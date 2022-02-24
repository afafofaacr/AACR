/**
 * Created by lauren.lezberg on 2/14/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('MyMembership init...');
        cmp.set("v.isLoading", true);
        var action = cmp.get("c.getMembershipData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.contactId", data.contactId);
                cmp.find('recordLoader').reloadRecord(true);
                cmp.set("v.membershipSub", data.membership);
                cmp.set("v.membershipType", data.membershipType);
                if(data.joinURL!=undefined) {
                    cmp.set("v.joinURL", data.joinURL);
                }
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve subscription data: Incomplete Callout');
                cmp.set("v.isLoading", false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve subscription data - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve subscription data: Unknown error");
                }
                cmp.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);

    },

    payInvoice : function(cmp, event, helper){
        console.log('MyMembership payInvoice...');

        var action = cmp.get("c.getInvoicePaymentURL");
        action.setParams({
           "contactId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = response.getReturnValue();
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve invoice payment url: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not retrieve invoice payment url - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve invoice payment url: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Redirects user back their incomplete application
     * @param cmp
     * @param event
     * @param helper
     */
    continueWithApplication : function(cmp, event, helper){
        console.log('MyMembership continueWithApplication...');

        cmp.set("v.isLoading", true);
        window.location.href = cmp.get("v.joinURL");
    },

    /**
     * @purpose Calls apex method to cancel application which deletes the most recent open sales order with a membership item. Upon success, user is redirected to membership categories page to
     * start a new application
     * @param cmp
     * @param event
     * @param helper
     */
    cancelOpenApplication : function(cmp, event, helper){
        console.log('MyMembership cancelOpenApplication...');

        cmp.set("v.isLoading", true);
        var action = cmp.get("c.cancelApplication");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = response.getReturnValue();
            }
            else if (state === "INCOMPLETE") {
                console.log('Could not retrieve subscription data: Incomplete Callout');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Could not cancel application - Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Could not retrieve subscription data: Unknown error");
                }
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Handles load of contact record and sets boolean variables that determine what information to display on the component for the particular user
     * @param cmp
     * @param event
     * @param helper
     */
    handleRecordUpdate: function(cmp, event, helper) {
        console.log('MyMembership handleRecordUpdate...');

        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            var currentContact = cmp.get("v.simpleRecord");
            cmp.set("v.awaitingPayment", currentContact.Application_Status__c=='Awaiting Payment');

            if(currentContact.RecordType.Name == 'Nonmember'){  //NONMEMBER
                if(currentContact.Application_Status__c == 'Incomplete Application' && cmp.get("v.joinURL")!=null){
                    cmp.set("v.incompleteApplication", true);
                } else if(currentContact.Application_Status__c == 'Pending Approval'){
                    cmp.set("v.pendingApproval", true);
                } else {
                    cmp.set("v.showApply", true);
                }
            }
            else if(currentContact.RecordType.Name == 'Member'){ //MEMBER
                cmp.find('benefits').set("v.hasBenefits", true);
                if(cmp.get("v.membershipSub")!=null){
                    var myDateArray = cmp.get("v.membershipSub").OrderApi__Current_Term_Start_Date__c.split("-");
                    var theDate = new Date(myDateArray[0],myDateArray[1]-1,myDateArray[2]);
                    if(currentContact.Member_Type__c == 'Student Membership' && currentContact.Membership_Status__c == 'Ineligible'){
                        cmp.set("v.noAccess", true);
                    } else if(theDate.getFullYear() > new Date().getFullYear()){
                        cmp.set("v.showUpcomingMembership", true);
                    } else {
                        cmp.set("v.showMembership", true);
                    }
                } else {
                    if(currentContact.Application_Status__c!='Awaiting Payment') {
                        cmp.set("v.noAccess", true);
                    }
                }
            }
            else if (currentContact.RecordType.Name == 'Prior Member' ){ //PRIOR MEMBER
                if(cmp.get("v.membershipSub")!=null){
                        if(currentContact.Application_Status__c!='Awaiting Payment') {
                            cmp.set("v.showMembership", true);
                        }
                } else {
                    if(currentContact.Application_Status__c!='Awaiting Payment') {
                        cmp.set("v.noAccess", true);
                    }
                }
            } // NO ACCESS
            else {
                cmp.set("v.noAccess", true);
            }
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
            cmp.set("v.errorMsg", 'Contact record error.')
        }
    },

    /**
     * @purpose Redirects user to membership categories page to start a new application
     * @param cmp
     * @param event
     * @param helper
     */
    goToApply : function(cmp, event, helper){
        console.log('MyMembership goToApply...');

        cmp.set("v.isLoading", true);
        window.location.href = '/apex/MembershipCategories';
    },

})