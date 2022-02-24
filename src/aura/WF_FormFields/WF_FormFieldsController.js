/**
 * Created by afaf.awad on 9/29/2021.
 */

({
    doInit: function(cmp,event,helper){
        const standardTypes = ['text', 'tel', 'date', 'number', 'email', 'checkbox']; //list of field types with say UI
        let field = cmp.get('v.field');
        let fieldType;
        // console.log('field to build....' +  JSON.stringify(field));

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
                        addClass(field.API_Name__c, 'customRadioCls');
                        break;
                    case 'msHorizontal' :
                        addClass(field.API_Name__c, 'multiSelectHorizontal');
                        break;
                    case 'msVertical' :
                        addClass(field.API_Name__c, 'multiSelectVertical');
                        break;
                }

                if (!field.sqRecord.isBold__c) {
                    console.log('unbold field = ' + field.API_Name__c);
                    addClass(field.API_Name__c, 'removeBoldCls');
                }

            } else {
                addClass(field.API_Name__c, 'removeBoldCls');
            }
        }
    },

});