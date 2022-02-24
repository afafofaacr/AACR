({
    initialize: function(component, event, helper) {
        console.log('selfRegister initialize...');

        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
        //component.set('v.extraFields', helper.getExtraFields(component, event, helper));
        // console.log("url: ", component.get("v.regConfirmUrl"))
    },
    
    handleSelfRegister: function (component, event, helpler) {
        console.log('selfRegister handleSelfRegister...');

        var account = component.find('companyLookup').get("v.selectedRecord");
        if(account!=null && account!=undefined) {
            var accountId = account.accountId;
            if (accountId != null && accountId!=undefined) {
                component.set("v.accountId", accountId);
            } else {
                component.set("v.accountId", null);
            }
        }
        component.set("v.processing", true);
        if(helpler.validateInput(component, event)){
            helpler.handleSelfRegister(component, event, helpler);
        } else {
            component.set("v.processing", false);
        }


    },

    handleEmailChange : function(cmp, event, helper){
        console.log('selfRegister handleEmailChange...');

        var email = cmp.find("email");
        var validReg1 = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        // console.log("validEmail: " + validReg1.test(email.get("v.value")));
        if(validReg1.test(email.get("v.value")) == false){
            email.setCustomValidity("You have entered an invalid format.");
            email.reportValidity();
        } else {
            email.setCustomValidity('');
            email.reportValidity();
        }
    },
    
    setStartUrl: function (component, event, helpler) {
        console.log('selfRegister setStartUrl...');

        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helpler){
        console.log('selfRegister onKeyUp...');

        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleSelfRegister(component, event, helpler);
        }
    }   
})