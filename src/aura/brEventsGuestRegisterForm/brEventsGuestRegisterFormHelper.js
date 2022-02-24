({
    getInputsData: function (cmp, callback) {
        const action = cmp.get('c.getRegisterFormInputs');

        action.setCallback(this, function(response){
            const state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {
                if (typeof callback === 'function') {
                    callback(JSON.parse(resVal));
                }
            }
        });

        $A.enqueueAction(action);
    },

    createFormInputs: function(component, inputsData) {
        let inputs = [];

        Object.entries(inputsData).forEach(function (el) {
            let label = el[1].label,
                required = false;

            if(el[1].required === 'true' || el[1].db_required === 'true') {
                required = true;
            }

            if(label === 'Business Phone') {
                label = 'Phone';
            }

            if(el[1].type === 'STRING' || el[1].type === 'EMAIL' || el[1].type === 'PHONE') {
                inputs.push(["lightning:input", {
                    "aura:id": "formInput",
                    "name": el[1].name,
                    "type": 'text',
                    "label": label,
                    "required": required
                }]);

            } else if (el[1].type === 'PICKLIST') {
                inputs.push(["c:BrSelect", {
                    "aura:id": "formInput",
                    "name": el[1].name,
                    "label": label,
                    "picklistField": el[1].name,
                    "required": required
                }]);

            } else {
                //TODO implement for other input types
            }
        });

        $A.createComponents(
            inputs,
            function(components, status, errorMessage){
                if (status === "SUCCESS") {
                    let body = component.get("v.body");
                    components.forEach(function (cmp) {
                        body.push(cmp);
                    });

                    component.set("v.body", body);
                }
            }
        );
    },

    registerForEvent: function (component, inputsArr) {
        let action = component.get('c.registerGuestForEvent');

        action.setParams({
            jsonString: JSON.stringify(inputsArr),
            eventId: component.get('v.eventId')
        });

        action.setCallback(this, function(response){
            const state = response.getState(),
                resVal = response.getReturnValue();

            if (state === 'SUCCESS') {
                const toastEvent = $A.get("e.force:showToast");
                component.set('v.isRegistered', true);
                component.set('v.isModalOpen', false);

                toastEvent.setParams({
                    "title": "Success!",
                    "message": "You have registered for event successfully."
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    }
})