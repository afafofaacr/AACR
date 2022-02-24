/**
 * Created by mitfity on 08.08.2019.
 */
({

    onStepChange: function (cmp, event) {
        var isSaving = cmp.get('v.isSaving');

        if (isSaving) {
            return;
        }

        var dietaryForm = cmp.find('dietaryForm');
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStep", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmp", cmpName);

        cmp.set('v.isSaving', true);
        dietaryForm.save();
        // dietaryForm.save().then($A.getCallback(function () {
        //     console.log('callback response...');
        //
        // })).catch($A.getCallback(function () {
        //     console.log('caught error....');
        // })).then($A.getCallback(function () {
        //     console.log('no longer saving...');
        //     cmp.set('v.isSaving', false);
        // }));
    },


    goNext : function(cmp, event, helper){
        cmp.set('v.isSaving', false);
        var status = event.getParam('status');

        if(status == 'success') {

            var stepId = cmp.get("v.nextStep");
            var cmpName = cmp.get('v.nextCmp');

            var navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        }


    }
})