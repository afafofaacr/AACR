/**
 * Created by afaf.awad on 1/13/2021.
 */

({

    doInit : function(cmp,event,helper){
        var action = cmp.get("c.getContactAccount");
        action.setParams({
            accountId: cmp.get('v.accountId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var account = response.getReturnValue();
                if(account.includes('(Individual)')){
                    cmp.set('v.affiliation','none');

                }
            } else {
                console.log('error');
            }
        });
        $A.enqueueAction(action);
    },

    saveAccount : function (cmp, event, helper) {
        cmp.set('v.processing', true);

        if(cmp.get('v.affiliation') == 'none'){
            helper.noAffiliation(cmp);
        }else{
            helper.saveContact(cmp);
        }
    },

    goBack : function (cmp){
        window.history.back();

    },

});