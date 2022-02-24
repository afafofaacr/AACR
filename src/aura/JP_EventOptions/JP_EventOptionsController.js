/**
 * Created by lauren.lezberg on 11/12/2019.
 */
({
    doInit: function (cmp, event, helper) {
        //console.log('eventId:' ,  helper.getEventId(cmp, event));
        cmp.set("v.processing", true);
        var eventId = helper.getEventId(cmp, event);
        if (eventId != null) {
            cmp.set("v.eventId", eventId);

            var action = cmp.get("c.getEventImages");
            action.setParams({
                "eventId": cmp.get("v.eventId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if (data) {
                        cmp.set("v.mainFileId", data[0]);
                        cmp.set("v.listFileId", data[1]);
                    }
                    cmp.set("v.processing", false);

                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete callout: getEventImages");
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }

    },

    getFields: function (cmp, event, helper) {
        var fieldSetName = cmp.find('regForm').get("v.value");
        if (fieldSetName != 'Custom') {

            var action = cmp.get("c.getFieldsInFieldset");
            action.setParams({
                "fieldsetName": 'Registration_' + fieldSetName
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    console.log("data: " + JSON.stringify(data));
                    var fields = data;
                    if(cmp.find('advocate').get("v.value")==true){
                        fields.push('Primary Stakeholder');
                        fields.push('Secondary Stakeholder');
                    }
                    cmp.set("v.fSetFields", fields);
                    cmp.set("v.showFields", true);

                } else if (state === "INCOMPLETE") {
                    console.log("Incomplete callout: getEventImages");
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        } else {
            cmp.set("v.showFields", true);
        }
    },

    closeModal: function (cmp, event, helper) {
        cmp.set("v.fSetFields", []);
        cmp.set("v.showFields", false);
    },

    regFormSelect: function (cmp, event, helper) {
        var value = event.getParam("value");
        if (value == 'Custom') {
            cmp.set("v.showCustomURL", true);
            if (cmp.find('fieldsetName') != undefined) {
                cmp.find("fieldsetName").set("v.value", null);
            }
        } else {
            if (cmp.find('customURL') != undefined) {
                cmp.find('customURL').set("v.value", null);
            }
            cmp.set("v.showCustomURL", false);
            cmp.find("fieldsetName").set("v.value", 'Registration_' + value);
        }
    },


    recordChange: function (cmp, event, helper) {
        if (!cmp.get("v.initialRecordLoaded")) {
            if (event.getParam("oldValue") == null && event.getParam("value") != null) {
                //console.log('rec (recordChange): ' + JSON.stringify(cmp.get("v.eventRecord")));
                var rec = cmp.get("v.eventRecord");
                //console.log('rec.Send_reminders__c: ' + rec.Send_reminders__c);

                /** REMINDERS **/
                // if (rec.Send_reminders__c) {
                //     cmp.set("v.reminderValue", 'On');
                // } else {
                //     cmp.set("v.reminderValue", 'Off');
                // }
                // var reminderHrs = rec.Reminder_Hours__c.split(';');
                // if (reminderHrs.length > 0) {
                //     if (reminderHrs[0] != 0 && reminderHrs[1] != 0 && reminderHrs[2] != 0) {
                //         //console.log('reminderHrs: ' + JSON.stringify(reminderHrs));
                //          cmp.find("firstReminder").set("v.value", reminderHrs[0]);
                //          cmp.find("secondReminder").set("v.value", reminderHrs[1]);
                //          cmp.find("thirdReminder").set("v.value", reminderHrs[2]);
                //     }
                // }

                if (rec.Draft__c) {
                    cmp.set("v.pubValue", 'Draft')
                } else {
                    cmp.set("v.pubValue", 'Published')
                }

                if (rec.Unlisted_Event__c) {
                    cmp.set("v.accessValue", 'Private');
                } else {
                    cmp.set("v.accessValue", 'Public');
                }

                cmp.set("v.selectedForm", rec.Event_Preferences_Form_Fieldset__c);


                cmp.set("v.eventRecord", rec);
            }
            cmp.set("v.initialRecordLoaded", true);
        }
    },

    handleSuccess: function (cmp, event, helper) {

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": cmp.get("v.nextStepId")});
        navEvt.setParams({"cmpName": cmp.get("v.nextCmpName")});
        navEvt.fire();
    },

    handleError: function (cmp, event, helper) {

        var navEvt = $A.get("e.c:JP_NavigateEvt");
        navEvt.setParams({"stepId": cmp.get("v.nextStepId")});
        navEvt.setParams({"cmpName": null});
        navEvt.fire();
    },

    handlePublishChange: function (cmp, event, helper) {
        var pub = event.getSource().get("v.value");

        if (pub == 'Published') {
            cmp.find("draft").set("v.value", false);
        } else {
            cmp.find("draft").set("v.value", true);
        }

    },

    handleAccessChange: function (cmp, event, helper) {
        var acc = event.getSource().get("v.value");

        if (acc == 'Public') {
            cmp.find("unlisted").set("v.value", false);
        } else {
            cmp.find("unlisted").set("v.value", true);
        }
    },

    handleSponsorChange: function (cmp, event, helper) {
        var settingValue = event.getSource().get("v.value") === 'true' ? true : false;
        var settingId = event.getSource().getLocalId();
        console.log('Setting = ' + settingValue);

        cmp.find(settingId + 'Field').set("v.value", settingValue);
        if(!settingId.includes('Logo') && !settingId.includes('View')) {
            cmp.set('v.' + settingId + 'On', settingValue);
        }
    },

    handleReminderChange: function (cmp, event, helper) {

        //console.log('handleReminderChange....');
        //console.log('Reminder button Value: ' + event.getSource().get("v.value"));

        if (event.getSource().get("v.value") == 'On') {

            var reminderHrs = cmp.find("reminderHrs").get("v.value").split(';');
            // console.log('reminderHrs: ' + reminderHrs + '(' + reminderHrs.length + ')');
            if (reminderHrs.length > 0) {
                //console.log('reminderHrs: ' + JSON.stringify(reminderHrs));
                if (reminderHrs[0] != 0) {
                    cmp.find("firstReminder").set("v.value", reminderHrs[0]);
                }
                if (reminderHrs[1] != 0) {
                    cmp.find("secondReminder").set("v.value", reminderHrs[1]);
                }
                if (reminderHrs[2] != 0) {
                    cmp.find("thirdReminder").set("v.value", reminderHrs[2]);
                }
            }
            cmp.find("reminders").set("v.value") == true;

            //console.log(' v.reminderValue to On'); 
            cmp.set("v.reminderValue", 'On');

            if (cmp.find("draft").get("v.value") == true) {
                cmp.set("v.pubValue", 'Draft')
            } else {
                cmp.set("v.pubValue", 'Published')
            }

            if (cmp.find("unlisted").get("v.value") == true) {
                cmp.set("v.accessValue", 'Private');
            } else {
                cmp.set("v.accessValue", 'Public');
            }

        } else {
            //console.log(' v.reminderValue to Off'); 
            cmp.set("v.reminderValue", 'Off');
        }
    },

    handleLoad: function (cmp, event, helper) {
        var eventId = helper.getEventId(cmp, event);

        if (eventId != null && cmp.get("v.eventId") == null) {
            cmp.set("v.eventId", eventId);
        }
        var rec = event.getParam("eventRecord");

        if (rec == undefined) {
            /** REMINDERS **/
            // if (cmp.find("reminders").get("v.value") == true) {
            //     cmp.set("v.reminderValue", 'On');
            //
            //     var reminderHrs = cmp.find("reminderHrs").get("v.value").split(';');
            //
            // //console.log('reminderHrs: ' + reminderHrs + '(' + reminderHrs.length + ')');
            //
            // if (reminderHrs.length > 0) {
            //     //console.log('reminderHrs: ' + JSON.stringify(reminderHrs));
            //
            //     if (reminderHrs[0] != 0) {
            //         cmp.find("firstReminder").set("v.value", reminderHrs[0]);
            //     }
            //
            //     if (reminderHrs[1] != 0) {
            //         cmp.find("secondReminder").set("v.value", reminderHrs[1]);
            //     }
            //
            //     if (reminderHrs[2] != 0) {
            //         cmp.find("thirdReminder").set("v.value", reminderHrs[2]);
            //     }
            // }
            //
            // }

            const getSponsorValue = auraId => cmp.find(auraId).get("v.value");
            const sponsorSettingGroup = ['landingPage', 'confirmPage','confirmEmail','reminderEmail'];
            sponsorSettingGroup.forEach(function(item){
                cmp.find(item).set("v.value", getSponsorValue(item + 'Field').toString());
                cmp.find(item+'Logo').set("v.value", getSponsorValue(item + 'LogoField').toString());
                cmp.set('v.' + item + 'On', getSponsorValue(item + 'Field'));
            })
            cmp.find('landingPageView').set("v.value", getSponsorValue('landingPageViewField').toString());
            cmp.find('confirmPageView').set("v.value", getSponsorValue('confirmPageViewField').toString());


            if (cmp.find("draft").get("v.value") == true) {
                cmp.set("v.pubValue", 'Draft')
            } else {
                cmp.set("v.pubValue", 'Published')
            }

            if (cmp.find("unlisted").get("v.value") == true) {
                cmp.set("v.accessValue", 'Private');
            } else {
                cmp.set("v.accessValue", 'Public');
            }

            var regForm = cmp.find("regForm").get("v.value");
            if (regForm == 'Custom') {
                cmp.set("v.showCustomURL", true);
            } else {
                cmp.find("fieldsetName").set("v.value", 'Registration_' + regForm);

            }

            if (cmp.find('virtualVenue').get("v.value") != null) {
                cmp.set("v.showVirtualSettings", true);
            }

            if(cmp.find('parent').get('v.value')!=null){
                cmp.find("access").set("v.disabled", true);
                cmp.set("v.accessValue", 'Private');
            }
        }


    },

    onStepChange: function (cmp, event, helper) {

        var stepId = event.getParam("stepId");
        var cmpName = event.getParam("cmpName");

        cmp.set("v.nextStepId", stepId);
        cmp.set("v.nextCmpName", cmpName);

        var pubValue = cmp.get("v.pubValue");
        var accessValue = cmp.get("v.accessValue");
        //console.log('accessValue: ' + accessValue);
        /** REMINDERS **/
        // var reminderValue = cmp.get("v.reminderValue");
        // console.log('remValue: ' + reminderValue);
        //
        // if(reminderValue == 'On'){
        //
        //     cmp.find("reminders").set("v.value", true);
        //
        //     console.log('firstReminder: ' + cmp.find('firstReminder').get("v.value"));
        //
        //     var reminderHours = '';
        //     reminderHours += cmp.find('firstReminder').get("v.value")!=''?cmp.find('firstReminder').get("v.value") + ';':'0;';
        //     reminderHours += cmp.find('secondReminder').get("v.value")!=''?cmp.find('secondReminder').get("v.value") + ';':'0;';
        //     reminderHours += cmp.find('thirdReminder').get("v.value")!=''?cmp.find('thirdReminder').get("v.value") + ';':'0;';
        //     //console.log('reminderHOurs: ' + reminderHours);
        //
        //     cmp.find("reminderHrs").set("v.value", reminderHours);
        // } else {
        //     cmp.find("reminders").set("v.value", false);
        // }

        if (pubValue == 'Draft') {
            cmp.find("draft").set("v.value", true);
        } else {
            cmp.find("draft").set("v.value", false);
        }

        if (accessValue == 'Public') {
            cmp.find("availability").set("v.value", true);
            cmp.find("unlisted").set("v.value", false);
        } else {
            cmp.find("availability").set("v.value", false);
            cmp.find("unlisted").set("v.value", true);
        }


       var isValid = true;

        if (cmp.find("confirmMessage").get("v.value") == null || cmp.find("confirmMessage").get("v.value") == '') {
            $A.util.addClass(cmp.find('confirmMessageBox'), "requiredError");
            helper.showToast(cmp, event, 'error', 'Please fill out all required fields.');
            isValid = false;
        }

        if (cmp.get("v.showVirtualSettings") && cmp.get("v.pubValue")=='Published' && !cmp.find('virtualDetails').get("v.hideDetails") && !cmp.find('virtualDetails').get("v.showPassword")){
            if (cmp.find('virtualDetails').find('externalEventId').get("v.value") == null || cmp.find('virtualDetails').find('externalEventId').get("v.value") == '') {
                $A.util.addClass(cmp.find('virtualDetails').find('externalEventId'), "slds-has-error");
                helper.showToast(cmp, event, 'error', 'Please fill out all required fields.');
                isValid = false;
            }
        }


        if(cmp.get("v.showVirtualSettings")){
            if(cmp.find('virtualDetails').get("v.showPassword")){
                if(cmp.find('virtualDetails').find('userId')==null|| cmp.find('virtualDetails').find('userId')==undefined){
                    helper.showToast(cmp, event, 'error', 'Please fill out all required fields.');
                    isValid = false;
                }
            }
            console.log('zoom user id: ' + cmp.find('virtualDetails').get("v.zoomUserId"));
            if(cmp.find('virtualDetails').get("v.detailId")==null){
            if(cmp.find('virtualDetails').get("v.zoomUserId")!=null && cmp.find('virtualDetails').get("v.zoomUserId")!=undefined) {
                var action = cmp.get("c.validateZoomData");
                action.setParams({
                    "eventId": cmp.get("v.eventId"),
                    "userId": cmp.find('virtualDetails').get("v.zoomUserId"),
                    "venueId": cmp.find('virtualVenue').get("v.value")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        isValid = response.getReturnValue();
                        console.log("isvalid: " + isValid);
                        if (isValid) {
                            $A.util.removeClass(cmp.find('confirmMessageBox'), "requiredError");
                            $A.util.removeClass(cmp.find('virtualDetails').find('externalEventId'), "slds-has-error");

                            if (cmp.get("v.showVirtualSettings")) {
                                cmp.find('virtualDetails').save();
                            }
                            cmp.find("editForm").submit();
                        } else {
                            helper.showToast(cmp, event, 'warning', 'There is already a zoom meeting under the same account with the same start time. Please select another account or go back and change the start date.');
                        }

                    } else if (state === "INCOMPLETE") {
                        console.log("Incomplete callout: getEventImages");
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            } else{
                if(isValid){
                    $A.util.removeClass(cmp.find('confirmMessageBox'), "requiredError");
                    $A.util.removeClass(cmp.find('virtualDetails').find('externalEventId'), "slds-has-error");

                    if (cmp.get("v.showVirtualSettings")) {
                        cmp.find('virtualDetails').save();
                    }
                    cmp.find("editForm").submit();
                }
            }
            } else{
                if(isValid){
                    $A.util.removeClass(cmp.find('confirmMessageBox'), "requiredError");
                    $A.util.removeClass(cmp.find('virtualDetails').find('externalEventId'), "slds-has-error");

                    if (cmp.get("v.showVirtualSettings")) {
                        cmp.find('virtualDetails').save();
                    }
                    cmp.find("editForm").submit();
                }
            }
        } else {
            console.log('validation complete...');

            if(isValid){
                $A.util.removeClass(cmp.find('confirmMessageBox'), "requiredError");
                $A.util.removeClass(cmp.find('virtualDetails').find('externalEventId'), "slds-has-error");

                if (cmp.get("v.showVirtualSettings")) {
                    cmp.find('virtualDetails').save();
                }
                cmp.find("editForm").submit();
            }
        }




    },

    handleMainUploadFinished: function (cmp, event, helper) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        cmp.set("v.mainFileId", uploadedFiles[0].documentId);

        var imgName = uploadedFiles[0].name.substring(0, uploadedFiles[0].name.lastIndexOf('.'));
        cmp.find("mainImg").set("v.value", imgName);

        helper.setFileAccessSettings(cmp, event, uploadedFiles[0].documentId, 'main');


    },

    handleListUploadFinished: function (cmp, event, helper) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        cmp.set("v.listFileId", uploadedFiles[0].documentId);

        var imgName = uploadedFiles[0].name.substring(0, uploadedFiles[0].name.lastIndexOf('.'));
        cmp.find("lstImg").set("v.value", imgName);

        helper.setFileAccessSettings(cmp, event, uploadedFiles[0].documentId, 'list');

    }
})