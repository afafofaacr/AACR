/**
 * Created by afaf.awad on 10/29/2021.
 */

({
    doInit: function (cmp, event, helper) {
        console.log('field to build....' + JSON.stringify(cmp.get('v.field')));
        const standardTypes = ['text', 'tel', 'date', 'number', 'email', 'checkbox']; //list of field types with say UI
        let field = cmp.get('v.field');
        let fieldType;

        if(field) {
            if (standardTypes.includes(field.Field_Type__c)) {
                if(!field.Output_Field__c) {
                    fieldType = 'standard';
                }else{
                    fieldType = 'outputText';
                }
            } else {
                fieldType = field.Field_Type__c;
            }

            cmp.set('v.fieldType', fieldType);

            if (fieldType == 'captcha') {
                // helper.setReCaptcha(cmp, event);
            }

            if (fieldType.includes('select')) {
                helper.selectOptions(cmp, field);
            }
        }
    },

    onRender: function (cmp, event, helper) {
        let addClass = (target, className) => {
            let cmpTarget = cmp.find(target);
            console.log('target == ' + target);
            $A.util.addClass(cmpTarget, className);
        }

        let field = cmp.get('v.field');
        let fieldType = cmp.get('v.fieldType');

        if (fieldType.includes('select')){
            if (field.sqRecord) {
                // console.log('field to style = ' + JSON.stringify(field));
                // console.log('question type = ' + field.sqRecord.Question_Type__c);
                switch (field.sqRecord.Question_Type__c) {
                    case 'ssHorizontal' :
                        addClass(field.Field_Type__c, 'customRadioCls');
                        break;
                    case 'msHorizontal' :
                        addClass(field.Field_Type__c, 'multiSelectHorizontal');
                        break;
                    case 'msVertical' :
                        addClass(field.Field_Type__c, 'multiSelectVertical');
                        break;
                }

                if (!field.sqRecord.isBold__c) {
                    console.log('unbold field = ' + field.Field_Type__c);
                    addClass(field.Field_Type__c, 'removeBoldCls');
                }

            } else {
                addClass(field.Field_Type__c, 'removeBoldCls');
            }
        }
    },

});