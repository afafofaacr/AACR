/**
 * Created by afaf.awad on 2/8/2021.
 */

({
    noAffiliation: function (cmp) {
        var action = cmp.get("c.createPersonAccount");
        action.setParams({
            contactId : cmp.get('v.contactId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse != null) {
                    // console.log('person account created = ' + JSON.stringify(storeResponse));
                    cmp.set("v.selectedRecord", storeResponse);
                    this.saveContact(cmp);
                } else {
                    cmp.set("v.Message", 'Could not create account. ');
                }
            } else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);
    },

    saveContact: function (cmp) {
        var account = cmp.get('v.selectedRecord');
        // console.log('account Returned = ' + JSON.stringify(account));
        var action = cmp.get("c.updateContact");
        action.setParams({
            accountId: account.accountId,
            contactId: cmp.get('v.contactId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // console.log('accountId = ' + response.getReturnValue());
                cmp.set('v.processing', false);
                window.history.back();

            } else {
                cmp.set('v.processing', false);
                cmp.set("v.Message", 'Could not create account. ');
            }
        });
        $A.enqueueAction(action);
    }
});