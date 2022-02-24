/**
 * Created by afaf.awad on 6/23/2021.
 */

({
    toggleBadAddress : function(cmp,event,helper){
        let address = cmp.get('v.address');
        address.isBadAddress = cmp.get('v.badMail');
        cmp.set('v.address', address);
    },

    onReasonChange : function(cmp,event,helper) {
        let address = cmp.get('v.address');
        let reason = cmp.find("mailRTS").get("v.value");
        address.rtsReason = reason;
        if (reason == 'Other (please enter into Other Return)') {
            cmp.set('v.mailOther', true);
        }
        cmp.set('v.address', address);
    },
});