/**
 * Created by afaf.awad on 1/29/2020.
 */

({
     goSave : function(cmp, event, helper){
         var navEvt = $A.get("e.c:JP_StepChangeEvt");
         navEvt.fire();
        },

    closeWindow : function(cmp, event, helper){
        var cmpName = event.getParam("cmpName");
        if(cmpName !== null){
            window.location.href = "/apex/MemberProfile";
        }
    },

    cancelPage : function (cmp) {
        window.close();
    }
});