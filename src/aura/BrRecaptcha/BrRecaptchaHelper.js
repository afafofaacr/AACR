({
    getCurrentDomain: function (component) {
        const action = component.get('c.getDomain');

        action.setCallback(this, function(response){
            const state = response.getState(),
                resVal = response.getReturnValue();
            if (state === 'SUCCESS') {
                component.set('v.domain', resVal);
            }
        });

        $A.enqueueAction(action);
    }
})