({
    showModal: function(component, event, helper) {
        helper.getInputsData(component, function(inputsData){
            helper.createFormInputs(component, inputsData);
            component.set('v.isModalOpen', true);
        });
    },

    hideModal: function(component) {
        component.set('v.isModalOpen', false);
        component.set('v.body', []);
    },

    registerForEvent: function (component, event, helper) {
        let inputs = component.find('formInput'),
            inputsArr = [],
            allValid = true;

        Object.entries(inputs).forEach(function (el) {
            if(!el[1].get('v.validity').valid) {
                allValid = false;
            }

            let inputObj = {};
            inputObj[el[1].get('v.name')] = el[1].get('v.value');
            inputsArr.push(inputObj);
        });

        if (allValid) {
            component.set('v.isErrors', false);
            helper.registerForEvent(component, inputsArr);
        } else {
            component.set('v.isErrors', true);
        }
    }
})