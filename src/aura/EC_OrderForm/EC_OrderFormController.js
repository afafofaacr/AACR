/**
 * Created by afaf.awad on 2/8/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('doInit OrderForm...');
        cmp.set("v.isLoading", true);
        cmp.set('v.orderId', helper.getOrderId(cmp));
        var action = cmp.get("c.getOrderInfo");
        action.setParams({
            orderId: cmp.get('v.orderId'),
            stepId : cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                if (data) {
                    //set variables
                    console.log('Order Data == ' + JSON.stringify(data.order));
                    cmp.set('v.countryData', data.countries);
                    cmp.set('v.attendeeTypeData',data.attendeeTypes);
                    cmp.set('v.institutionTypeData', data.institutionTypes);
                    cmp.set('v.degreeData',data.degrees);
                    cmp.set('v.organData',data.organs);
                    cmp.set('v.researchData',data.researchAreas);
                    cmp.set('v.exOrder', data.order);

                    if(data.order.Countries__c) {
                        cmp.set('v.countrySelected', data.order.Countries__c.split(';'));
                    }
                    if(data.order.Attendee_Type__c) {
                        cmp.set('v.attendeeSelected', data.order.Attendee_Type__c.split(';'));
                    }
                    if(data.order.Degrees__c) {
                        cmp.set('v.degreeSelected', data.order.Degrees__c.split(';'));
                    }
                    if(data.order.Institution_Type__c) {
                        cmp.set('v.institutionSelected', data.order.Institution_Type__c.split(';'));
                    }
                    if(data.order.Organ_Sites__c) {
                        cmp.set('v.organSelected', data.order.Organ_Sites__c.split(';'));
                    }
                    if(data.order.Research_Area_of_Expertise__c) {
                        cmp.set('v.researchSelected', data.order.Research_Area_of_Expertise__c.split(';'));
                    }
                    cmp.set("v.isLoading", false);

                    }
            } else if (state === "INCOMPLETE") {
                cmp.set('v.processing', false);
            } else if (state === "ERROR") {
                cmp.set('v.processing', false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    addSelection: function (cmp, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        console.log("selected rows = " + JSON.stringify(selectedRows));
    },

    updateAudience: function (cmp,event,helper){
        cmp.set('v.processing',true);
       helper.saveRecord(cmp)
           .then(result => {
               console.log('response returned == ' + result );
               var evt = $A.get("e.c:EC_AudienceEvent");
                   evt.fire();
               cmp.set('v.processing',false);

           })
           .catch(error => {
               console.log('Could not update Audience Count. ' + error);
               cmp.set('v.processing',false);

           });

    },

    handleSave : function(cmp,event,helper){
        console.log('saving record....');
        var stepId = event.getParam("stepId");
        cmp.set("v.nextStepId", stepId);
        var cmpName = event.getParam("cmpName");
        cmp.set("v.nextCmpName", cmpName);

        if(helper.validate(cmp)) {
            cmp.set("v.isLoading", true);
            var isSuccess = helper.saveRecord(cmp);

            if (isSuccess) {
                helper.handleSuccess(cmp);
            } else {
                helper.handleError(cmp);
            }
        }
    },

});