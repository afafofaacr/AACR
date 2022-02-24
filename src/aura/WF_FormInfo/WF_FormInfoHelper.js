/**
 * Created by afaf.awad on 9/28/2021.
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

    addSurveyIdToURL : function(cmp, surveyId){
        var key = 'c__survey';
        var value = surveyId;
        var kvp = document.location.search.substr(1).split('&');
        // console.log('kvp: ', kvp);
        var i = kvp.length;
        var x;
        while (i--) {
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
        // console.log('kvp: ' + kvp.join('&'));

        window.history.pushState({urlPath: 'c__BAMContainer?' + kvp.join('&')}, document.title, 'c__BAMContainer?' + kvp.join('&'));
    },

    addEmbeddedCode : function (cmp,surveyId){
        console.log('adding embed code');
        let action = cmp.get("c.createEmbeddedCode");
        action.setParams({
            surveyId: surveyId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                if (data) {
                    console.log('embed code created');
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: addEmbeddedCode');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - addEmbeddedCode: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in addEmbeddedCode");
                }
            }
        });
        $A.enqueueAction(action);
    },

});