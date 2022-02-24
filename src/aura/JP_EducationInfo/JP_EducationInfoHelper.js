/**
 * Created by lauren.lezberg on 1/28/2019.
 */
({
    createNewRecord : function(cmp, event){
        console.log('JP_EducationInfo createNewRecord...');

        cmp.find("recordEditor").getNewRecord(
            "Education__c", // sObject type (entityAPIName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = cmp.get("v.record");
                var error = cmp.get("v.recordError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + rec.sobjectType);
                }
            })
        );
    },

    createRecordWrapper : function(record){
        console.log('JP_EducationInfo createRecordWrapper...');
        var newRecord = {};
        newRecord.Id = record.Id;
        newRecord.Name = record.Name;
        newRecord.EducationStatus = record.Current_Education_Status__c;
        newRecord.Degree = record.Degree__c;
        newRecord.GradDate = record.Date_of_Expected_Graduation__c;
        newRecord.DegreeYear = record.Degree_Completion_Year__c;
        return newRecord;

    },

    validateRecord : function(cmp, event){
        console.log('JP_EducationInfo validateRecord...');

        var allValid = cmp.find('educationField').reduce(function (validSoFar, inputCmp) {
            if(inputCmp.value==undefined){
                inputCmp.showHelpMessageIfInvalid();
            }
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);


        return allValid;
    },

    validateForm : function(cmp, event){
        console.log('JP_EducationInfo validateForm...');

        var isValid = true;
        cmp.set("v.recordError", null);
        if(cmp.get("v.educationRecords").length>0) {

            var memberType = cmp.find("memberType").get("v.value");
            var eduStatus = cmp.find('educationStatus').get("v.value");
            if(eduStatus!=null) {
                if(memberType!=null) {
                    if (memberType.includes('Associate')) {
                        if (eduStatus == 'Post-Baccalaureate' || eduStatus == 'Undergraduate' || eduStatus == 'High School') {
                            isValid = false;
                            cmp.set("v.recordError", 'This is not a valid current education status for this membership type.');
                        } else if (eduStatus == 'N/A') {
                            isValid = false;
                            this.sendIneligibleEmail(cmp);
                        }
                    } else if (memberType.includes('Student')) {
                        if (eduStatus != 'Post-Baccalaureate' && eduStatus != 'Undergraduate' && eduStatus != 'High School') {
                            isValid = false;
                            this.sendIneligibleEmail(cmp);
                        }
                    }
                }
            } else {
                isValid = false;
                $A.util.addClass(cmp.find('educationStatus'), 'slds-has-error');
                // cmp.find('currentStatus').submit();
            }
        } else {
            isValid = false;
            var form = cmp.find("entryForm");
            form.set("v.title", 'You must enter at least one education record');

            var border = cmp.find("border");
            $A.util.addClass(border, 'emptyError');
        }

        return isValid;
    },

    sendIneligibleEmail : function(cmp){
        console.log('JP_EducationInfo sendIneligibleEmail...');

        var action = cmp.get("c.deferMember");
        action.setParams({
            "contactId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.ineligible", true);
                cmp.find('appStatus').set("v.value", 'Deferred');
                cmp.set("v.recordError", 'Congratulations on your achievement. Based on your selection, you may no ' +
                    'longer qualify for your current membership category. Please select the transfer button to review ' +
                    'the membership categories available and begin the transfer process. If you require assistance or ' +
                    'have any questions, please contact membership@aacr.org.');
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
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
                cmp.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    },

    deleteRecord : function(cmp, event, recordToDelete){
        console.log('JP_EducationInfo deleteRecord...');

        var action = cmp.get("c.deleteEducation");
        action.setParams({
           "record" : recordToDelete
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.createNewRecord(cmp , event);
                cmp.set("v.isLoading", false);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incomplete Callout');
                cmp.set("v.isLoading", false);
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
                cmp.set("v.isLoading", false);
            }

        });
        $A.enqueueAction(action);
    },

    /**
     * @purpose Retrieves sales order id parameter from URL
     * @param cmp
     * @returns {string}
     */
    getSalesOrderId : function(cmp){
        var name ='salesOrder';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );

        if(results!=null) {

            var SOId = results[1];
            return SOId;
        }

        return null;
    },
})