/**
 * Created by lauren.lezberg on 10/15/2020.
 */

({

    handleLoad : function(cmp, event, helper){

        var isOpen = cmp.find('cmeOpen').get("v.value");
        if(isOpen){
            cmp.set("v.value", 'on');
        } else {
            cmp.set("v.value", 'off');
        }

        var surveyLink = cmp.find("surveyLink").get("v.value");
        if(surveyLink==null || surveyLink == undefined){
            cmp.set("v.isDisabled", true);
        } else {
            cmp.set("v.isDisabled", false);
        }

    },


    handleChange : function(cmp, event, helper){
        if(cmp.get("v.value")=='on'){
            cmp.find("cmeOpen").set("v.value", true);
        } else {
            cmp.find("cmeOpen").set("v.value", false);
        }
        cmp.find('editForm').submit();
    }
});