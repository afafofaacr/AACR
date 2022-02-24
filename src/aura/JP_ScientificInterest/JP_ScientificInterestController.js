/**
 * Created by lauren.lezberg on 1/15/2019.
 */
({
    doInit : function(cmp, event, helper){
        console.log('JP_ScientificInterest init...');

        var action = cmp.get("c.getScientificInterestData");
        action.setParams({
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();

                cmp.set("v.contactRecord", data.currentContact);
                cmp.set("v.primaryResearchOptions", helper.getList(cmp, event,data.primaryResearchOptions));
                cmp.set("v.majorFocusOptions", helper.getList(cmp, event, data.majorFocusOptions));
                cmp.set("v.organSiteOptions", data.organSiteOptions);
                cmp.set("v.specificResearchOptions", data.specificResearchOptions);
                cmp.set("v.addResearchOptions", data.addResearchOptions);

                if(data.currentContact.Major_Focus__c!=null) {
                    cmp.set("v.majorFocusValues", data.currentContact.Major_Focus__c.split(';'));
                }

                if(data.currentContact.Organ_Sites__c!=null) {
                    cmp.set("v.organSiteValues", data.currentContact.Organ_Sites__c.split(';'));
                }
                if(data.currentContact.Specific_Research_Areas__c!=null) {
                    cmp.set("v.specificResearchValues", data.currentContact.Specific_Research_Areas__c.split(';'));
                }
                if(data.currentContact.Additional_Research_Areas__c!=null) {
                    cmp.set("v.addResearchValues", data.currentContact.Additional_Research_Areas__c.split(';'));
                }

            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
            }
            else if (state === "ERROR") {
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

    handleSave : function(cmp, event, helper){
        console.log('JP_ScientificInterest handleSave...');

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");
        if(stepId!=cmp.get("v.stepId")) {
            // console.log('scientific interest data saving');
            if (helper.validateData(cmp, event)) {
                cmp.set("v.isLoading", true);
                helper.saveData(cmp);

                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": stepId});
                navEvt.setParams({"cmpName": cmpName});
                navEvt.fire();
            } else {
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": cmp.get("v.stepId")});
                navEvt.setParams({"cmpName": null});
                navEvt.fire();
            }
        }
    },

    


})