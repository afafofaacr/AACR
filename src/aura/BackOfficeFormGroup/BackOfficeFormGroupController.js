/**
 * Created by afaf.awad on 12/2/2019.
 */

({
    doInit: function (cmp, event, helper) {

        let fieldResponses = cmp.get("v.fieldResponses");
        let formFields = cmp.get("v.formFields");
        let formGroup = cmp.get("v.formGroup");
        let groupFields = [];

        if (formGroup) {
            if (fieldResponses && fieldResponses.length) {

                let fieldQuestions = [];

                fieldResponses.forEach(function (fr) {
                    if (fr.PagesApi__Field__r.PagesApi__Field_Group__c == formGroup.Id) {
                        fieldQuestions.push(fr);
                    }
                });
                cmp.set("v.fieldsList", fieldQuestions);
            } else {
                formFields.forEach(function (field) {
                    if (field.PagesApi__Field_Group__c === formGroup.Id) {
                        groupFields.push(field);
                    }
                });
                cmp.set("v.fieldsList", groupFields);
            }
        }
    },

});