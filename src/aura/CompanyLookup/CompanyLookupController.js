/**
 * Created by afaf.awad on 7/29/2020.
 */

({
    doInit : function(cmp,event, helper){
        helper.dunAuthenticate(cmp);

        var contact = cmp.get('v.contactId');
        console.log('contactId: ' + contact);
        if(contact != null && contact!='' && contact!='') {
            var action = cmp.get("c.getAccountInfo");
            action.setParams({
                contactId: contact
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    console.log('account = ' + JSON.stringify(storeResponse));
                    cmp.set("v.listOfSearchRecords", storeResponse);
                 
                    var childCmp = cmp.find("clResult");
                    childCmp.getAccount();

                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.log("Error:: " + errors[0].message);
                }
            });
            $A.enqueueAction(action);
        }



    },

    onfocus : function(component,event,helper){
        // $A.util.addClass(component.find("mySpinner"), "slds-show");
        // var forOpen = component.find("searchRes");
        // $A.util.addClass(forOpen, 'slds-is-open');
        // $A.util.removeClass(forOpen, 'slds-is-close');
        // // Get Default 5 Records order by createdDate DESC
        // var getInputkeyWord = '';
        // helper.searchHelper(component,event,getInputkeyWord);
    },

    onblur : function(component,event,helper){
        // component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

    },

    keyPressController : function(component, event, helper) {
        console.log('calling keyPressController...');
        // get the search Input keyword
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 1 then open the lookup result List and
        // call the helper
        // else close the lookup result List part.
        if( getInputkeyWord.length > 1 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{
            component.set("v.listOfSearchRecords", null );
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },

    // function for clear the Record Selaction
    clear :function(component,event,helper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField");

        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');

        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');

        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );
    },

    // This function call when the end User Select any record from the result list.
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONENT event
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        console.log("selectRecord returned ==" + JSON.stringify(selectedAccountGetFromEvent));
        if(selectedAccountGetFromEvent.accountId.match(/^[0-9]+$/)){
            var newAccount = helper.createAccount(component,event,selectedAccountGetFromEvent);
        }
        else {
            component.set("v.selectedRecord", selectedAccountGetFromEvent);
        }

        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');

        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');

        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');

    },
    
//     noAffiliation : function(cmp,event,helper){
//         console.log('Creating a Person Account...');
//         //make new account of person's name (individual)
//         var action = cmp.get("c.createPersonAccount");
//         action.setParams({
//             recordName : cmp.get('v.firstname') +' '+ cmp.get('v.lastname')  + ' (Individual)'
//         });
//         action.setCallback(this, function(response) {
//             var state = response.getState();
//             if (state === "SUCCESS") {
//                 var storeResponse = response.getReturnValue();
//                 if(storeResponse!=null) {
//                     cmp.set("v.listOfSearchRecords", storeResponse);
//                     var childCmp = cmp.find("clResult");
//                     childCmp.getAccount();
//                 } else {
//                     cmp.set("v.Message", 'Could not create account. ');
//                 }
//             } else {
//                 console.log('error');
//             }
//         });
//         $A.enqueueAction(action);
//     },
//
//     goBack : function (cmp) {
//         window.history.back();
//     },
//
//     saveAccount : function (cmp, event, helper) {
//         console.log('Saving Account...');
//         cmp.set('v.processing', true);
//         var account = cmp.get('v.selectedRecord');
//         // console.log('accountId = ' + account.accountId);
//         // console.log('contactId = ' + cmp.get('v.contactId'));
//         var action = cmp.get("c.updateContact");
//         action.setParams({
//             accountId : account.accountId,
//             contactId : cmp.get('v.contactId')
//         });
//         action.setCallback(this, function(response) {
//             var state = response.getState();
//             if (state === "SUCCESS") {
//                 window.history.back();
//                 // console.log('accountId = ' + response.getReturnValue());
//                 cmp.set('v.processing', false);
//
//             } else {
//                 cmp.set('v.processing', false);
//                 cmp.set("v.Message", 'Could not create account. ');
//                 }
//
//         });
//         $A.enqueueAction(action);
//
//     }

});