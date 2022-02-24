/**
 * Created by lauren.lezberg on 3/30/2020.
 */
({

    closeModal : function(cmp, event, helper){
        console.log('closing modal...');

        var applicationEvent = $A.get("e.c:AreYouSureResponseEvt");
        applicationEvent.setParams({"confirm" : false})
        applicationEvent.fire();


        cmp.set("v.isOpen", false);
    },

    confirmModal : function(cmp, event, helper){
        console.log('confirming modal....');

        var applicationEvent = $A.get("e.c:AreYouSureResponseEvt");
        applicationEvent.setParams({"confirm" : true});
        if(cmp.get("v.cmpId")!=null) {
            applicationEvent.setParams({"cmpId" : cmp.get("v.cmpId")});
        }
        applicationEvent.fire();

        cmp.set("v.isOpen", false);

    }
})