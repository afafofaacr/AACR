/**
 * Created by afaf.awad on 5/27/2021.
 */

({
    doInit : function(cmp,event,helper){
        let object = cmp.get('v.objectName');
        if(object){
            cmp.set('v.objectChoice', object);
        }
        console.log('objectName = ' + object);

    },

    refresh : function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    cancel : function(cmp, event, helper){
        console.log('closing modal...');
        helper.closeModal(cmp);
    },

    handleSave : function(cmp, event, helper){
        console.log('call validations....');
        let btnID = event.getSource().getLocalId();
        helper.validateFields(cmp,btnID);
    },

});