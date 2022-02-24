/**
 * Created by afaf.awad on 7/29/2020.
 */

({
    dunAuthenticate : function(cmp){
        console.log('intializing...getting token...');
        var action = cmp.get("c.dunAuthentication");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('token = ' + storeResponse);
                cmp.set('v.token', storeResponse);
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error:: " + errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    searchHelper : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'token' : component.get('v.token')
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                console.log('response = ' + JSON.stringify(storeResponse));
                if (storeResponse == null) {
                    console.log('response  is null....');

                    this.suggestCompany(component,event,getInputkeyWord);
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }else if (state === "ERROR") {
                var errors = response.getError();
                    console.log("Error:: " + errors[0].message);
                }

        });
        // enqueue the Action
        $A.enqueueAction(action);

    },

    suggestCompany : function(component,event,getInputkeyWord) {

        console.log('getting suggested company...');
        var action = component.get("c.getSuggestedCompany");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('suggested response = ' + storeResponse);
                component.set("v.listOfSearchRecords", storeResponse);
                // component.set("v.Message", "We did not find a matching Organization is our System");
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error:: " + errors[0].message);
            }

        });
        $A.enqueueAction(action);
    },

    createAccount : function (cmp, event, newRecord) {
        console.log('Creating new Acount...');
        var action = cmp.get("c.createNewAccount");
        action.setParams({
            'accountName': newRecord.accountName,
            'duns' : newRecord.accountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('new account = ' + JSON.stringify(storeResponse));
                cmp.set("v.selectedRecord", storeResponse);
            }else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Error:: " + errors[0].message);
            }
        });
        $A.enqueueAction(action);

    }

});