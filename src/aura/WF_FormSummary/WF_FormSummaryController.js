/**
 * Created by afaf.awad on 10/29/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('doInit Summary...');
        cmp.set("v.isLoading", true);
        cmp.set('v.recordId', helper.getSurveyId(cmp));
        cmp.set("v.isLoading", false);
    },

    previewInTab : function(cmp,event,helper){

        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: "c__WF_FormPreview"
            },
            state: {
                "c__survey": cmp.get('v.recordId')
            }
        };
        var navService = cmp.find("navService");
        navService.generateUrl(pageReference).then($A.getCallback(url => {
            console.log('Using Navigate'+url);
            //---add this line which allows you to open url in new tab instead of navService
            window.open('https:'+url,'_blank');
        }),$A.getCallback(error => console.log(error)));

    },

    goPrevious: function (cmp, event, helper) {
        var action = cmp.get("c.getPreviousStep");
        action.setParams({
            stepId: cmp.get('v.stepId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var stepId = response.getReturnValue();
                if (stepId) {
                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": stepId});
                    navEvt.setParams({"cmpName": 'WF_FormPublishing'});
                    navEvt.fire();
                }
            } else if (state === "INCOMPLETE") {
                console.log('State is Incomplete');
            } else if (state === "ERROR") {
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

    goBack: function (cmp, event, helper) {
        window.history.back();
    },

    handleSubmit : function (cmp,event,helper){
        var navLink = cmp.find("navService");
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Survey__c',
                recordId : cmp.get('v.recordId')
            },
        };
        navLink.navigate(pageRef, true);
    }


});