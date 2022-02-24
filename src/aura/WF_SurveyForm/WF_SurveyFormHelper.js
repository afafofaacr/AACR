/**
 * Created by afaf.awad on 11/5/2021.
 */

({
    getSurveyId : function(cmp){
        var name ='c__survey';
        var url = location.href;
        name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
        name = name.toLowerCase();
        var regexS = "[\\?&]"+name+"=([^&#]*)";
        var regex = new RegExp( regexS, "i" );
        var results = regex.exec( url );
        if(results!=null){
            var SOId=results[1];
            return SOId;
        }
        return null;
    },

    validate : function(cmp){
        console.log('validating...');
        // console.log('FormField == ' + JSON.stringify(cmp.get('v.formFields')));
        let formFields = cmp.get('v.formFields');
        let isValid = formFields.reduce(function (validSoFar, field) {
            // console.log('validSOFar == ' + validSoFar);
            // console.log('field == ' + JSON.stringify(field));
            if (!validSoFar) {
                if (!field.Output_Field__c) {
                    if(field.isRequired__c) {
                        return field.input == "" ? false : true;
                    }
                } else {
                    return validSoFar;
                }
            }else{
                return validSoFar;
            }
        }, true);
        console.log('isValid == ' + isValid);
        return isValid;
    },

    getInputFields : function(cmp,event,helper){
        let formFields = cmp.get('v.formFields');
        let inputFields = [];

        formFields.forEach(f => {
            if(f.input){
                inputFields.push(f);
            }
        });
        console.log('inputFields == ' + JSON.stringify(inputFields));

        return inputFields;
    }
});