/**
 * Created by afaf.awad on 2/15/2021.
 */

({
    getOrderId : function(cmp){
        var name ='c__orderId';
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

    updateEmailTemplate: function(cmp){
        var action = cmp.get("c.updateEmailRecord");
        action.setParams({
            "emailId": cmp.get('v.emailId'),
            "emailBody" : cmp.find("bodyInput").get("v.value"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                // console.log('data: ' + data);
                if(data) {
                    cmp.find("emailPreview").refreshPreview();
                }
            } else if (state === "INCOMPLETE") {
                // do something
                return false;
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                return false;
            }
        });
        $A.enqueueAction(action);
    },

    validate : function(cmp) {
        console.log('validating email info...');
        let isValid = true;

        let validateField = auraId => {
            var field = cmp.find(auraId);
            var fieldVal = field.get("v.value");
            if (!fieldVal) {
                $A.util.addClass(field, 'slds-has-error');
                isValid = false;
            } else {
                $A.util.removeClass(field, 'slds-has-error');
            }
            return isValid;
        }

        var name = validateField('emailName');
        // var action = validateField('actionName');
        // var link = validateField('actionLink');
        var subject = validateField('emailSubject');
        var body = validateField('bodyField');

        if(!name || !subject || !body){
            isValid = false;
        }
        console.log('isvalid = ' +  isValid);
        // var name = cmp.find('emailName');
        // var nameVal = name.get("v.value");
        // console.log('nameVal==' + nameVal);
        // if (!nameVal) {
        //     $A.util.addClass(name, 'slds-has-error');
        //     isValid = false;
        // } else {
        //     $A.util.removeClass(name, 'slds-has-error');
        // }

        return isValid;
    },


        handleEmailBodyFormats : function (cmp){
        // console.log('bodyInput== ' + (cmp.find("bodyInput").get("v.value") ));
        // console.log('bodyField== ' + (cmp.find("bodyField").get("v.value") ));

        if(cmp.find("bodyInput").get("v.value") != cmp.find("bodyField").get("v.value")){
            if(cmp.find("bodyInput").get("v.value")) {

                var appliedFormats = {
                    size: 16
                };
                var editor = cmp.find("bodyInput");
                editor.setFormat(appliedFormats);
                // console.log('bodyInput: ' + cmp.find("bodyInput").get("v.value"));
            }

            cmp.find('bodyField').set("v.value", cmp.find("bodyInput").get("v.value"));
        }

    },

    hideMessage : function(cmp){
        $A.util.removeClass(cmp.find('toastMsg'), 'slds-show');
        $A.util.addClass(cmp.find('toastMsg'), 'slds-hide');
    },
});