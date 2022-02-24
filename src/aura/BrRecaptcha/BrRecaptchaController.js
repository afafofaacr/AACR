({
    doInit: function (component, event, helper){
        helper.getCurrentDomain(component);
        window.addEventListener('message', function(event) {
            const vfOrigin = 'https://' + component.get('v.domain');
            if (event.origin === vfOrigin) {
                if (event.data === 'Unlock'){
                    component.set('v.disabled', '');
                }
                if (event.data === 'registerEvent'){

                    component.getEvent('registerEvent').fire();
                }
            }
        }, false);
    }
})