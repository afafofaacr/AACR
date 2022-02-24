/**
 * Created by lauren.lezberg on 2/28/2019.
 */
({

    doInit : function(cmp, event, helper){
        console.log('JP_Nominators init...');
        var action = cmp.get("c.getNominationData");
        action.setParams({
            "salesOrderId" : helper.getSalesOrderId(cmp),
            "stepId" : cmp.get("v.stepId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var itemName = data.itemName;
                cmp.set("v.itemName", itemName);
                var nominators = data.nominations;
                cmp.set("v.contactId", data.contactId);

                if(nominators.length>0){
                    var nominator = {};
                    nominator.emailAddr = nominators[0].npe4__RelatedContact__r.OrderApi__Preferred_Email__c;
                    nominator.memberNo = nominators[0].npe4__RelatedContact__r.AACR_ID__c;
                    nominator.isVerified = nominators[0].npe4__Status__c == 'Current';
                    cmp.set("v.nominator1", nominator);
                    if(nominators.length==2) {
                        nominator = {};
                        nominator.emailAddr = nominators[1].npe4__RelatedContact__r.OrderApi__Preferred_Email__c;
                        nominator.memberNo = nominators[1].npe4__RelatedContact__r.AACR_ID__c;
                        nominator.isVerified = nominators[1].npe4__Status__c == 'Current';
                        cmp.set("v.nominator2", nominator);
                    } else {
                        cmp.set("v.nominator2", {});
                    }
                }
                else {
                    cmp.set("v.nominator1", {});
                    cmp.set("v.nominator2", {});
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
        cmp.set("v.isLoading", false);


    },


    /**
     * @purpose Calls apex method to verify nominator making sure member number and email are unique from other nominator. Upon success, nominator is highlighted and buttons are disabled.
     * Upon failure, nominator receives and error message
     * @param cmp
     * @param event
     * @param helper
     */
    verify: function(cmp, event, helper){
        console.log('JP_Nominators verify...');

        var nom = event.getSource().get('v.value');
        var nominator = cmp.get("v." + nom);
        var compareNom;
        if(nom == 'nominator1'){
            compareNom = cmp.get("v.nominator2");
        } else {
            compareNom = cmp.get("v.nominator1");
        }

        if((nominator.emailAddr!=null && nominator.emailAddr == compareNom.emailAddr) || (nominator.memberNo!=null && nominator.memberNo == compareNom.memberNo )){
            nominator.isVerified = false;
            cmp.set("v." + nom, nominator);
        } else {
            var action = cmp.get("c.verifyNominator");
            action.setParams({
                "contactId": cmp.get("v.contactId"),
                "emailAddress": nominator.emailAddr,
                "memberNumber": nominator.memberNo
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if (data != null) {
                        cmp.set("v." + nom, data);
                        if(nom == 'nominator1') {
                            $A.util.removeClass(cmp.find("nominator1"), 'customError');
                        } else {
                            $A.util.removeClass(cmp.find("nominator2"), 'customError');
                        }
                    } else {
                        nominator.isVerified = false;
                        cmp.set("v." + nom, nominator);

                    }
                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout');
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
        }
    },

    /**
     * @purpose Handles join process stepChange event, validates nominator data and file input and redirects forward or backward upon success
     * Upon failure, error messages are displayed and user does not move forward or backward
     * @param cmp
     * @param event
     * @param helper
     */
    handleSave : function(cmp, event, helper){
        console.log('JP_Nominators handleSave...');

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

            if (helper.validate(cmp)) {

                cmp.set("v.isLoading", true);

                if (cmp.get("v.itemName") != 'Student Membership') {
                    var nominators = [];
                    nominators.push(cmp.get("v.nominator1"));
                    nominators.push(cmp.get("v.nominator2"));

                    var action = cmp.get("c.saveNominationData");
                    action.setParams({
                        "contactId": cmp.get("v.contactId"),
                        "nominators": nominators,
                        "stepId": cmp.get("v.stepId")
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var data = response.getReturnValue();

                            if(data.isSuccess){
                                var navEvt = $A.get("e.c:JP_NavigateEvt");
                                navEvt.setParams({"stepId": stepId});
                                navEvt.setParams({"cmpName": cmpName});
                                navEvt.fire();
                            } else {
                                var navEvt = $A.get("e.c:JP_NavigateEvt");
                                navEvt.setParams({"stepId": cmp.get("v.stepId")});
                                navEvt.setParams({"cmpName": null});
                                navEvt.fire();

                                cmp.set("v.isLoading", false);
                                cmp.set("v.response", data);
                            }

                        } else if (state === "INCOMPLETE") {
                            console.log('Incomplete Callout');
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
                } else {
                    cmp.find("recordEditForm").submit();

                    var navEvt = $A.get("e.c:JP_NavigateEvt");
                    navEvt.setParams({"stepId": stepId});
                    navEvt.setParams({"cmpName": cmpName});
                    navEvt.fire();
                }
            } else { 
                var navEvt = $A.get("e.c:JP_NavigateEvt");
                navEvt.setParams({"stepId": cmp.get("v.stepId")});
                navEvt.setParams({"cmpName": null});
                navEvt.fire();
            }
    },
    
})