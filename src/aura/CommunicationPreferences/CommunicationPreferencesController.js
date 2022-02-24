/**
 * Created by lauren.lezberg on 7/1/2021.
 */

({
    handleLoad : function(cmp, event){
        var record = event.getParam("recordUi");

        /** set preferred email & phone **/
        cmp.set("v.preferredPhone", record.record.fields.OrderApi__Preferred_Phone_Type__c.value);
        cmp.set("v.preferredEmail", record.record.fields.OrderApi__Preferred_Email_Type__c.value);

        /** get isMinor **/
        var birthday = record.record.fields.Birthdate.value;
        if(birthday!=null) {
            // console.log('birthday: ' + birthday);
            var dateParts = birthday.split('-');
            var birthdayDate = new Date(dateParts[0], dateParts[1], dateParts[2]);

            var ageDifMs = Date.now() - birthdayDate.getTime();
            // console.log('ageDifMs: ' + ageDifMs);
            var ageDate = new Date(ageDifMs);
            // console.log('ageDate: ' + ageDate);
            var finalAge = Math.abs(ageDate.getUTCFullYear() - 1970);
            // console.log('age: ' + finalAge);
            cmp.set("v.isMinor", finalAge<=17);

        }


    },

    handleSubmit : function (cmp, event, helper){
        console.log('submitting form...');
        cmp.find('editForm').submit();
        cmp.set("v.isLoading", true);
    },

    handleSuccess : function(cmp){
        console.log("SUCCESS");
        cmp.set("v.isLoading", false);
    },

    handleError : function(cmp){
        console.log("ERROR");
        cmp.set("v.isLoading", false);
    },

    handlePhoneTypeChange : function(cmp){
        var phoneType = cmp.find('phoneType').get("v.value");
        cmp.set("v.preferredPhone", phoneType);
    },

    handleEmailTypeChange : function(cmp){
        var emailType = cmp.find('emailType').get("v.value");
        cmp.set("v.preferredEmail", emailType);
    }
});