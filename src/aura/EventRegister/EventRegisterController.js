/**
 * Created by lauren.lezberg on 7/9/2020.
 */
({

    doInit: function (cmp, event, helper) {
        console.log('register init');
        var eventId = helper.getEventId(cmp);
        // cmp.find("segment").set("v.eventId", eventId);
        // console.log('eventId: ' + eventId);

        var action = cmp.get("c.getRegistrationFieldset");
        action.setParams({
            "eventId": eventId,
            "salesOrderId": helper.getSalesOrderId(cmp)
        })
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log('data: ' + JSON.stringify(data));

                if (data != null) {
                    // console.log('salesOrder: ' + data.salesOrderId);
                    if (data.salesOrderId != null && helper.getSalesOrderId(cmp) == null) {
                        //add salesorder to url
                        var key = 'salesOrder';
                        var value = data.salesOrderId;
                        var kvp;
                        if (document.location.search.substr(1).includes('%26')) {
                            kvp = document.location.search.substr(1).split('%26');
                        } else {
                            kvp = document.location.search.substr(1).split('&');
                        }

                        // console.log('kvp: ', kvp);
                        var i = kvp.length;
                        var x;
                        while (i--) {
                            kvp[i] = kvp[i].replace('%3D', '=');
                            x = kvp[i].split('=');

                            if (x[0] == key) {
                                x[1] = value;
                                kvp[i] = x.join('=');
                                break;
                            }
                        }

                        if (i < 0) {
                            kvp[kvp.length] = [key, value].join('=');
                        }

                        window.history.pushState({urlPath: 'JP_Container?' + kvp.join('&')}, document.title, 'JP_Container?' + kvp.join('&'));
                    }

                    cmp.set("v.showWorkshopFields", data.showWorkshopFields);
                    cmp.set("v.showPrePostDoc", data.showPrePostDoc);
                    cmp.set("v.salesOrderId", data.salesOrderId);
                    cmp.set("v.fieldsetName", data.fieldsetName);
                    cmp.set("v.contactId", data.contactId);
                    cmp.set("v.showAdvocate", data.advocate);
                    cmp.set("v.showJointFields", data.showJointFields);
                } else {
                    window.location.href = '/LiveEventsList?ac__id=' + eventId;
                }

            } else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout:doInit');
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

    closeModal: function (cmp, event, helper) {
        cmp.set("v.fieldCheckMessage", null);
        cmp.set("v.confirmed", true);
    },

    onStepChange: function (cmp, event, helper) {
        console.log('onStepChange...');
        cmp.set("v.isLoading", true);
        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");


        var nextStep = {};
        nextStep.stepId = stepId;
        nextStep.cmpName = cmpName;

        cmp.set("v.nextStep", nextStep);


        var isValid = true;
        if ((!cmp.get("v.showAdvocate") || (cmp.get("v.showAdvocate") && cmp.find('advocateFields').validate())) && (cmp.get("v.showPrePostDoc") && cmp.find('pdocCert').validate()) || !cmp.get("v.showPrePostDoc")) {
            if (cmp.get("v.fieldsetName") == 'Registration_Advanced' && !cmp.get("v.confirmed")) {
                console.log('country: ' + cmp.find('fSet').get("v.selectedCountry"));
                if (cmp.find('fSet').get("v.selectedCountry") == null) {
                    isValid = false;
                    cmp.find('fSet').find('mailingCountry').showHelpMessageIfInvalid();
                    cmp.set("v.fieldCheckMessage", 'There are fields that are incomplete that could affect your conference rate. Please check the following fields: (Country, State)');
                } else if (cmp.find('fSet').get("v.selectedState") == null && (cmp.find('fSet').get("v.selectedCountry") == 'US' || cmp.find('fSet').get("v.selectedCountry") == 'CA')) {
                    isValid = false;
                    cmp.set("v.fieldCheckMessage", 'There are fields that are incomplete that could affect your conference rate. Please check the following fields: (State)');
                    cmp.find('fSet').find('mailingState').showHelpMessageIfInvalid();
                }
            }

            if(cmp.find('healthSafety').get("v.participantId")){
                if (cmp.find('healthSafety').find('attestation').get("v.value") == false) {
                    isValid = false;
                    cmp.find('healthSafety').set("v.hasError", true);
                } else {
                    isValid = true;
                    cmp.find('healthSafety').set("v.hasError", false);
                }
            }

            if (isValid) {

                cmp.find("gdprCert").find("gdprForm").submit();

                if (cmp.get("v.showPrePostDoc")) {
                    cmp.find("pdocCert").find("pForm").submit();
                }

                if (cmp.get("v.showAdvocate")) {
                    cmp.find('advocateFields').find('editForm').submit();
                }

                if (cmp.get("v.showJointFields")) {
                    cmp.find('jointFields').find('editForm').submit();
                }

                if (cmp.get("v.showWorkshopFields")) {
                    cmp.find('workshopFields').find('pForm').submit();
                }

                if(cmp.find('healthSafety').get("v.participantId")!=null){
                    cmp.find('healthSafety').find('editForm').submit();
                }

                window.setTimeout(function(){
                    cmp.find('fSet').save();
                }, 3000);

            } else {
                cmp.set("v.isLoading", false);
            }
        } else {
            cmp.set("v.isLoading", false);
        }

    },

    goToNextStep: function (cmp, event, helper) {
        console.log('goToNextStep...');

        var eventId = helper.getEventId(cmp);
        // console.log('next: eventId='+ eventId);

        // console.log('isValid advocateFields: ' + cmp.find('advocateFields').get("v.isValid"));
        // console.log('isValid prePostDocFields: ' + cmp.find('pdocCert').get("v.isValid"));



        if (((cmp.get("v.showPrePostDoc") && cmp.find('pdocCert').get("v.isValid")) || !cmp.get("v.showPrePostDoc")) && cmp.find("fSet").get("v.isValid") && (!cmp.get("v.showAdvocate") || cmp.get("v.showAdvocate") && cmp.find('advocateFields').get("v.isValid"))) {
            console.log('valid form...');

            var action = cmp.get("c.updateTicket");
            action.setParams({
                "eventId": eventId,
                "salesOrderId": helper.getSalesOrderId(cmp)
            })
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // if (cmp.get("v.showAdvocate")) {
                    //     var isAdvocate = cmp.find('advocateFields').find('isAdvocate').get('v.value');
                    //     if (!isAdvocate) {
                    //         var redirect = false;
                    //         //Check for advocate fields & redirect accordingly
                    //         if (cmp.find('advocateFields').find('pStakeholder').get('v.value') != null) {
                    //             redirect = true;
                    //         } else if (cmp.find('advocateFields').find('sStakeholder').get('v.value') != null) {
                    //             redirect = true;
                    //         }
                    //         if (redirect) {
                    //             window.location.href = '/AdvocateApplicationConfirmation?eventId=' + helper.getEventId(cmp);
                    //         } else {
                    //             var navEvt = $A.get("e.c:JP_NavigateEvt");
                    //             navEvt.setParams({"stepId": cmp.get("v.nextStep").stepId});
                    //             navEvt.setParams({"cmpName": cmp.get("v.nextStep").cmpName});
                    //             navEvt.fire();
                    //         }
                    //     }
                    // } else {

                        var navEvt = $A.get("e.c:JP_NavigateEvt");

                        navEvt.setParams({"stepId": cmp.get("v.nextStep").stepId});
                        navEvt.setParams({"cmpName": cmp.get("v.nextStep").cmpName});
                        navEvt.fire();
                    // }

                } else if (state === "INCOMPLETE") {
                    console.log('Incomplete Callout:doInit');
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
            console.log('invalid form...');
            cmp.set("v.isLoading", false);
            var navEvt = $A.get("e.c:JP_NavigateEvt");

            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }

        //check if
    }
})