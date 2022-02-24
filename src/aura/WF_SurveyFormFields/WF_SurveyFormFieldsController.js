/**
 * Created by afaf.awad on 11/5/2021.
 */

({
    doInit: function (cmp, event, helper) {
        // console.log('field to build....' + JSON.stringify(cmp.get('v.field')));
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

            if (fieldType == 'Captcha') {
                helper.setReCaptcha(cmp, event);
            }

            if (fieldType.includes('select')) {
                helper.selectOptions(cmp, field);
            }

            if(fieldType == 'image'){
                helper.getSurveyImage(cmp, field);
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

    verifyCaptcha : function(cmp,event,helper){
        let isVerified = event.getParam("verified");
        console.log('is captcha verified == ' + isVerified);
        cmp.set('v.captchaVerify', isVerified);

    },


    handleSubmit : function (cmp,event,helper) {
        console.log('call Buttons to validate...');
        let appEvent = $A.get("e.c:WF_AppEvent");
        appEvent.setParams({'action' : 'validate'});
        appEvent.fire();
    },

    handleInput : function(cmp,event,helper){
        let field = cmp.get('v.field');
        if(field.Field_Type__c == 'checkbox') {
            console.log('updating checkbox input');
            field.input = cmp.find('input').get('v.checked');
            console.log('input == ' + field.input);
            cmp.set('v.field', field);
        }
    },

    /**
     * Validating for UI only. Real validation is on parent (WF_SurveyForm)
     */
    validateField : function(cmp,event,helper){
        console.log('validating...');
        var validateFields = cmp.find('input');
        var isValid;
        if (validateFields) {
            isValid = [].concat(validateFields).reduce((validSoFar, input) => {
                input.showHelpMessageIfInvalid();
                return validSoFar && input.get('v.validity').valid;
            }, true);
        }
    }

});