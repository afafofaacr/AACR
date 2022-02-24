/**
 * Created by lauren.lezberg on 6/14/2021.
 */

({
    openAddressesPage : function(cmp, event, helper){
        // window.open('/UpdateAddressInformation?contactId=' + cmp.get('v.recordId'), '_blank');
        cmp.set("v.modalOpen", true);
    },

    closeModal : function(cmp, event,helper){
        cmp.set('v.modalOpen', false);
    }
});