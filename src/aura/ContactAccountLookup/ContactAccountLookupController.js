/**
 * Created by lauren.lezberg on 2/26/2019.
 */
({

    doInit : function(cmp, event, helper){
        console.log('ContactAccountLookup init...');

        if(cmp.get("v.affiliatedWithSelf")){
            cmp.set("v.affiliation", 'none');
            cmp.set("v.accountId", null);
        } else {
            cmp.set("v.affiliation", 'affiliated');
        }
    },


    scriptsLoad : function(cmp, event, helper){
        console.log('ContactAccountLookup scriptsLoad...');

        jQuery("document").ready(function() {
            var input = $("#input-10");
            input.change(function () {
            });
        });
    },

    changeAffiliation : function(cmp, event, helper){
        console.log('ContactAccountLookup changeAffiliation...');
        if(cmp.get("v.affiliatedWithSelf")){
            cmp.set("v.affiliation", 'none');
            cmp.set("v.v.selectedRecord.accountId", null);
        } else {
            cmp.set("v.affiliation", 'affiliated');
        }
    },

    toggleAffiliation : function(cmp, event, helper){
        console.log('ContactAccountLookup toggleAffiliation...');

        if(cmp.get("v.affiliation")=='none'){
            cmp.set("v.selectedRecord.accountId", null);
        }
    },

    setAccountId : function(cmp, event, helper){
        console.log('ContactAccountLookup setAccountId...');

        cmp.set("v.accountId", event.getSource().get("v.value")[0]);
    }




})