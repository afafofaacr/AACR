/**
 * Created by lauren.lezberg on 3/23/2021.
 */

({
    handleLoad : function(cmp, event, helper){
        var eventStart = new Date(cmp.find('startDate').get("v.value"));
        var today = new Date();
        if(today>= eventStart){
            cmp.set("v.isDisabled", true);
        } else {
            cmp.set("v.isDisabled", false);
            var isOpen = cmp.find('refundsOpen').get("v.value");
            if (isOpen) {
                cmp.set("v.value", 'on');
            } else {
                cmp.set("v.value", 'off');
            }
        }

    },


    handleChange : function(cmp, event, helper){
        if(cmp.get("v.value")=='on'){
            cmp.find("refundsOpen").set("v.value", true);
        } else {
            cmp.find("refundsOpen").set("v.value", false);
        }
        cmp.find('editForm').submit();
    }
});