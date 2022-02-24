/**
 * Created by lauren.lezberg on 10/15/2020.
 */

({
    handleLoad : function(cmp, event, helper){

        var isOpen = cmp.find('lopOpen').get("v.value");
        if(isOpen){
            cmp.set("v.value", 'on');
        } else {
            cmp.set("v.value", 'off');
        }

        var letter = cmp.find("letter").get("v.value");
        if(letter==null || letter == undefined){
            cmp.set("v.isDisabled", true);
        } else {
            cmp.set("v.isDisabled", false);
        }

    },


    handleChange : function(cmp, event, helper){
        if(cmp.get("v.value")=='on'){
            cmp.find("lopOpen").set("v.value", true);
        } else {
            cmp.find("lopOpen").set("v.value", false);
        }
        cmp.find('editForm').submit();
    }
});