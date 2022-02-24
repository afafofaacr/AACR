/**
 * Created by afaf.awad on 11/5/2021.
 */

({

    selectOptions : function(cmp, field){
        let choices = field.Question_Responses__c.split('\n');
        let options = [];
        choices.forEach(c => {
            options.push({label: c, value: c});
        })
        // console.log('options = ' + JSON.stringify(options));
        cmp.set('v.options', options);
    },

    getSurveyImage: function (cmp, field){
        console.log('getting Image...' + field.Id + ' imageID == ' + field.ImageId__c);
        let action = cmp.get("c.getSurveyFormImage");
        action.setParams({
            recordId: field.Id,
            imageId: field.ImageId__c
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let data = response.getReturnValue();
                console.log('imageURL == ' + data);
                if (data) {
                    cmp.set('v.imageUrl', data);
                }
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: getSurveyFormImage');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - getSurveyFormImage: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in getSurveyFormImage");
                }
            }
        });
        $A.enqueueAction(action);
    },

    setReCaptcha: function (cmp) {
        console.log('setReCaptcha');
        let action = cmp.get("c.getSiteDomain");
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let url = response.getReturnValue();
                console.log('hostURL returned == ' + url);
                cmp.set('v.siteURL', url);
            } else if (state === "INCOMPLETE") {
                console.log('Incomplete: ReCaptacha');
            } else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message - ReCaptacha: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error in ReCaptacha");
                }
            }
        });
        $A.enqueueAction(action);
    },

    isValid: function (cmp, id) {
        console.log('validating...');
        var validateFields = cmp.find('input');
        console.log('validateFields...' + validateFields);
        var isValid;
        console.log('isValid var...');
        if (validateFields) {
            console.log('validating...');
            isValid = [].concat(validateFields).reduce(function (validSoFar, input) {
                input.showHelpMessageIfInvalid();
                console.log('validSoFar = ' + validSoFar + 'input.valid == ' +  input.get('v.validity').valid);
                return validSoFar && input.get('v.validity').valid;
            }, true);
        }
        // console.log('isValid == ' + isValid);

        return isValid;
    },

    doRecaptchaVerification: function(component, event, token) {
        const action = component.get('c.verifyResponse');

        action.setParams({response: token});

        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === 'SUCCESS') {
                const valid = response.getReturnValue();
                if (!valid) {
                    component.set('v.formMessage', 'Sorry, we could not verify you.');
                } else if (valid) {
                    component.set('v.formMessage', '');

                    // reCaptcha validated! Here is where we'll submit the form.
                }
            } else {
                const errors = response.getError();
                component.set('v.formMessage', 'Sorry, an error occurred.');
            }
        });

        $A.enqueueAction(action);
    },
});