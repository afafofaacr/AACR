/**
 * Created by afaf.awad on 9/14/2020.
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

              //ReCaptcha
              var domain = defaults.domains;
              cmp.set('v.domain', domain);
              console.log('domain = ' + domain);
              window.addEventListener('message', function(event) {
                  const vfOrigin = 'https://' + cmp.get('v.domain');
                  console.log('vfOrgin = ' + vfOrigin);
                  if (event.origin === vfOrigin) {
                      if (event.data === 'Unlock'){
                          cmp.set('v.disabled', '');
                      }
                      if (event.data === 'registerEvent'){

                          cmp.getEvent('registerEvent').fire();
                      }
                  }
              }, false);

              console.log('loading');

              cmp.set('v.isLoading', false);
          }
          });

      $A.enqueueAction(action);
    },

    saveContactInfo : function(cmp, event, helper){
        var isValid = helper.validateInput(cmp);
        if(isValid) {
            helper.registerVolunteer(cmp, event);
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
    }

});