/**
 * Created by afaf.awad on 10/20/2021.
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

    validate : function(cmp) {
        console.log('validating form info...');
        let validateField = auraId => {
            var field = cmp.find(auraId);
            var fieldVal = field.get("v.value");
            if (!fieldVal) {
                $A.util.addClass(field, 'slds-has-error');
                return false;
            } else {
                $A.util.removeClass(field, 'slds-has-error');
                return true;
            }
        }

        let requiredFields = ['Name', 'description', 'formType', 'systemTag', 'authOptions', 'prefCategory', 'optIn'];
        let validArray = [];

        requiredFields.forEach(rf => {
            validArray.push(validateField(rf));
        })

        if(validArray.includes(false)){
            return false;
        }else{
            return true;
        }
    },

    showHideDate : function(cmp){
        let publishtype = cmp.find('publishMethod').get('v.value');
        cmp.set('v.showDate',publishtype == 'Schedule' ? true : false);
    },
});