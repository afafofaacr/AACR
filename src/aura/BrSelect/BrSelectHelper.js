/**
 * Created by lovandos on 2019-03-27.
 */
({
    retrievePicklistOptions: function (component, picklistField) {
        const action = component.get('c.getPicklistOptions');

        action.setParams({
            picklistField: picklistField
        });

        action.setCallback(this, function(response){
            const state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {
                component.set('v.options', resVal);
            }
        });

        $A.enqueueAction(action);
    },
})