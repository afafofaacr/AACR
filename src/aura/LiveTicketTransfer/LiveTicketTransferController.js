/**
 * Created by lauren.lezberg on 2/1/2021.
 */

({

    openModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", true);
    },

    closeModal : function(cmp, event, helper){
        cmp.set("v.modalOpen", false);
    }
});