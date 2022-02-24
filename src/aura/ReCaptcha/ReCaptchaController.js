/**
 * Created by afaf.awad on 11/8/2021.
 */

({
    onScriptLoaded : function(component, event, helper) {
        jQuery(function($){
            let iframe = $('.recaptchaFrame');
            iframe = iframe[0];
            iframe.height = '100px';
        });
    },

    doInit : function(component, event, helper) {
        window.addEventListener("message", function (event) {
            let hostOrigin = component.get('v.hostUrl').slice(0, -1); // 'https://aacr--uat.sandbox.my.site.com';
            // console.log('hosturl from cmp == ' + hostOrigin);
            if (event.origin !== hostOrigin) {
                return;
            }

            if (event.data && event.data.action && event.data.action === 'verified') {
                component.set('v.hasreCaptchaVerified', true);
            } else if (event.data && event.data.action && event.data.action === 'error') {
                component.set('v.hasreCaptchaVerified', false);
            } else if (event.data && event.data.action && event.data.action === 'expired') {
                component.set('v.hasreCaptchaVerified', false);
            } else if (event.data && event.data.action && event.data.action === 'loaded') {
                component.set('v.hasreCaptchaVerified', false);
            }
            if (event.data && event.data.action && event.data.action === 'heightChange') {
                let iframe = $('.recaptchaFrame');
                iframe = iframe[0];
                // console.log('height ====' + event.data.height);
                iframe.height = event.data.height;
            }
        }, false);
    },

    callCaptchaEvt : function (cmp,event,helper){
        let appEvent = $A.get("e.c:ReCaptchaEvent");
        appEvent.setParams({'verified' : cmp.get('v.hasreCaptchaVerified')});
        appEvent.fire();
    }
});