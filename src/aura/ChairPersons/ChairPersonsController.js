/**
 * Created by lauren.lezberg on 1/14/2020.
 */
({

    doInit : function(cmp, event, helper){
        helper.getInitialData(cmp, event);
    },


    openModal : function(cmp, event, helper){
      cmp.set("v.newModalOpen", true);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.newModalOpen", false);
    },

    confirmDelete : function(cmp,event, helper){
        var selectedId = event.getSource().get('v.value');

        cmp.find("confirmModal").set("v.message", 'Are you sure you want to delete this record? ');
        cmp.find("confirmModal").set("v.isOpen", true);

        cmp.set("v.selectedId", selectedId);
    },

    handleResponseClick : function(cmp, event, helper){
        // console.log('handleResponseClick...');

        var reject = event.getParam('reject');
        var confirm = event.getParam('confirm');

        var cmpId = event.getParam('cmpId');

        if(confirm && cmpId == cmp.get("v.cmpId")) {
            helper.deleteSelectedChair(cmp, event);
        }
    },



    handleSubmit : function(cmp, event, helper){
        console.log('handleSubmit... ' );
        event.preventDefault();

        var useForInvite = cmp.find("invite").get("v.value");
        if(useForInvite == true){
            var roles = cmp.find("roles").get("v.value");

            if(roles!=null) {
                var roleArray = roles.split(';');
                if (roleArray.length > 1) {
                    cmp.set("v.errorMsg", 'Chairpersons used for speaker invitations can only have one role.');
                } else {
                    cmp.set("v.errorMsg", null);
                    cmp.find('cpNew').submit();

                }
            } else {
                cmp.set("v.errorMsg", 'Chairpersons used for speaker invitations must have a role.');
            }
        } else {
            cmp.find('cpNew').submit();
        }

    },

    handleSuccess : function(cmp, event, helper){
        helper.getInitialData(cmp, event);
        

    },

    openEditSpeaker: function (cmp, event, helper) {
        var speakerId = event.getSource().get("v.value");
        cmp.set("v.newModalOpen", true);

        if(speakerId!=null) {
            cmp.find("cpNew").set("v.recordId", speakerId);
        }
    },

    handleScheduleUpdate : function(cmp, event, helper){
        cmp.set("v.speakerModalOpen", false);
    },
})