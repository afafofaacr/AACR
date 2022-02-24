/**
 * Created by lauren.lezberg on 5/8/2020.
 */
({

    doInit : function(cmp, event, helper){
        console.log('UpdatePersonalInformation init...');

        cmp.find("personalInfo").updateContact();
    },

    handleCancel : function(cmp, event, helper){
        console.log('UpdatePersonalInformation handleCancel...');

        window.location.href = document.referrer;
        // window.close();
    },

    handleSave : function(cmp, event, helper){
        console.log('UpdatePersonalInformation handleSave...');

        var stepChangeEvt = $A.get("e.c:JP_StepChangeEvt");
        stepChangeEvt.setParams({"stepId": cmp.find("personalInfo").get("v.stepId")});
        stepChangeEvt.setParams({"cmpName": 'JP_PersonalInformation'});
        stepChangeEvt.fire();

    },

    handleNavigate : function(cmp, event, helper){
        console.log('UpdatePersonalInformation handleNavigate...');

        var cmpName = event.getParam("cmpName");
        if(cmpName!=null){
            var referrer = document.referrer;
            window.location.href = referrer;
        }
    }
})