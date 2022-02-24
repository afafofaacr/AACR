({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    validateInput : function(cmp, event){
        console.log('selfRegister validateInput...');
        var isValid = true;
        var firstName = cmp.find("firstname");
        if(firstName.get("v.value")==null || firstName.get("v.value") == undefined || firstName.get("v.value") == ''){
            isValid = false;
            firstName.set("v.validity", {valid:false, badInput:true});
            firstName.showHelpMessageIfInvalid();
        }
        var lastName = cmp.find("lastname");
        if(lastName.get("v.value")==null || lastName.get("v.value") == undefined || lastName.get("v.value") == ''){
            isValid = false;
            lastName.set("v.validity", {valid:false, badInput:true});
            lastName.showHelpMessageIfInvalid();
        }
        var email = cmp.find("email");
        var validReg1 = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        // console.log("validEmail: " + validReg1.test(email.get("v.value")));
        if(email.get("v.value")==null || email.get("v.value") == undefined || email.get("v.value") == '' || validReg1.test(email.get("v.value")) == false){
            isValid = false;
            email.setCustomValidity("You have entered an invalid format.");
            email.reportValidity();
        } else {
            email.setCustomValidity('');
            email.reportValidity();
        }
        var password = cmp.find("password");
        if(password.get("v.value")==null || password.get("v.value") == undefined || password.get("v.value") == ''){
            isValid = false;
            password.set("v.validity", {valid:false, badInput:true});
            password.showHelpMessageIfInvalid();
        } else {
            var str = password.get("v.value");
            var numberReg = /\d/g;
            if(str.length <8 || !numberReg.test(str) || !str.match(/[a-z]/) || !str.match(/[A-Z]/)){
                isValid = false;
                password.setCustomValidity('Password must contain 8 characters: 1 uppercase, 1 lowercase and 1 numeric digit.');
                password.reportValidity();
            }
        }
        return isValid;
    },
    
    handleSelfRegister: function (component, event, helpler) {
        console.log('selfRegister handleSelfRegister...');

        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
       // var confirmPassword = component.find("confirmPassword").get("v.value");

        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        
        startUrl = decodeURIComponent(startUrl);

        var action = component.get("c.selfRegister");
        action.setParams({
            firstname:firstname,
            lastname:lastname,
            email:email,
            password:password,
            confirmPassword:password,
            accountId:accountId,
            regConfirmUrl:regConfirmUrl,
            extraFields:extraFields,
            startUrl:startUrl,
            includePassword:includePassword
        });
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage",rtnValue);
                component.set("v.showError",true);
                component.set("v.processing", false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        console.log('selfRegister getExtraFields...');

        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    }    
})