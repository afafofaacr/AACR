/**
 * Created by afaf.awad on 7/16/2020.
 */

({
    doInit : function(cmp, event, helper){
        // cmp.find("sciInts").updateContact();
    },

    handleCancel : function(cmp, event, helper){
        // window.location.href = document.referrer;
        window.history.back();
    },

    handleSave : function(cmp, event, helper){
        var stepChangeEvt = $A.get("e.c:JP_StepChangeEvt");
        stepChangeEvt.setParams({"stepId": ''});
        console.log('stepId: ' + cmp.find("sciInts").get("v.stepId"));
        stepChangeEvt.setParams({"cmpName": 'JP_ScientificInterest'});
        stepChangeEvt.fire();
    },

    handleNavigate : function(cmp, event, helper){
        var cmpName = event.getParam("cmpName");
        if(cmpName!=null){
            //     window.location.href = '/MemberProfile';
            // cmp.set("v.showCmp", false);
            // var referrer = document.referrer;
            // console.log('referrer: ' + referrer);
            // window.location.href = referrer; //'/MemberProfile';
            window.history.back();
        }
    }
})