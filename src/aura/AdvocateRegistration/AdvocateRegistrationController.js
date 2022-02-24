/**
 * Created by afaf.awad on 9/21/2020.
 */

({
    doInit : function (cmp,event, helper){

       var action = cmp.get("c.getDefaultData");
       action.setParams({
          recordType : cmp.get('v.recordType')
       });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var defaults = response.getReturnValue();
                cmp.set('v.recordType', defaults.recordTypeId);
                //COUNTRIES
                var data = defaults.countries;
                var custs = [];
                for(var key in data){
                    custs.push({label:data[key], value:key});
                }
                cmp.set("v.countryList", custs);

                //ADDRESS
                var address = {};
                address.street1 = '';
                address.street2 = '';
                address.street3 = '';
                address.countryCode = '';
                address.stateCode = '';
                address.city = '';
                address.zip = '';
                cmp.set("v.address", address);

                //STATES
                // if(defaults.states!=null && defaults.states.length!=0){
                //     data = defaults.states;
                //     var custs = [];
                //     for(var key in data){
                //         custs.push({label:data[key], value:key});
                //     }
                //     cmp.set("v.statesList", custs);
                // }

                //SECONDARY STAKEHOLDER
                data = defaults.stakeholderOptions;
                    var custs = [];
                    for(var key in data){
                        custs.push({label:data[key], value:data[key]});
                    }
                    cmp.set("v.stakeholderOptions", custs);

                //RECAPTCHA
                var domain = defaults.domains;
                cmp.set('v.domain', domain);
                // console.log('domain = ' + domain);
                window.addEventListener('message', function(event){
                    const vfOrigin = 'https://' + cmp.get('v.domain');
                    if (event.origin === vfOrigin) {
                        if (event.data === 'Unlock'){
                            cmp.set('v.disabled', '');
                        }
                        if (event.data === 'registerEvent'){
                            cmp.getEvent('registerEvent').fire();
                        }
                    }
                }, false);

                cmp.set('v.isLoading', false);
            }
        });

        $A.enqueueAction(action);
    },

    saveContactInfo : function(cmp, event, helper){
        var isValid = helper.validateInput(cmp);
        if(isValid) {
            helper.registerAdvocate(cmp, event);
        } else {
            cmp.set("v.isLoading", false);
        }

    },

    handleFieldUpdate : function(cmp, event, helper){
        if(cmp.get('v.isLoading')) {
            var fieldId = event.getSource().get("v.id");
            console.log("fieldId: " + fieldId);
            if (cmp.find(fieldId).get('v.value') == null || cmp.find(fieldId).get("v.value") == undefined) {
                $A.util.addClass(cmp.find(fieldId), 'slds-has-error');
                $A.util.removeClass(cmp.find(fieldId + '_help_msg'), 'slds-hide');
            } else {
                $A.util.removeClass(cmp.find(fieldId), 'slds-has-error');
                $A.util.addClass(cmp.find(fieldId + '_help_msg'), 'slds-hide');
            }
        }
    },

    handleNameField : function(cmp,event,helper){
            var name = cmp.find("conName");
            var isValid = name.checkValidity();
            if(isValid) {
                $A.util.removeClass(cmp.find(fieldId), 'slds-has-error');
                $A.util.addClass(cmp.find(fieldId + '_help_msg'), 'slds-hide');
            }
            else {
                $A.util.addClass(cmp.find(fieldId), 'slds-has-error');
                $A.util.removeClass(cmp.find(fieldId + '_help_msg'), 'slds-hide');
            }
    },

    doNothing : function(cmp,event,helper){
        //To satisfy Address Component
    },

    stakeholderChange: function (cmp, event, helper) {
        var primaryOption = cmp.get('v.primaryStakeholder');
        if (primaryOption != 'Other') {
            var action = cmp.get("c.getStakeholderOptions");
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    var options = [];
                    for (var key in data) {
                        options.push({label: data[key], value: data[key]});
                    }
                    options.forEach(function (choice, idx) {
                        if (choice.label == primaryOption) {
                            options.splice(idx, 1);
                        }
                    });
                    cmp.set("v.stakeholderOptions", options);
                }
            });

            $A.enqueueAction(action);
        }
    },

});