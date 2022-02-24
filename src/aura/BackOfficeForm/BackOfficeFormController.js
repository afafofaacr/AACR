/**
 * Created by afaf.awad on 11/20/2019.
 */

({
    doInit: function (cmp, event, helper) {
        let salesOrderId = helper.getSalesOrderId(cmp);
        cmp.set("v.salesOrderId", salesOrderId);
        console.log("SalesOrder: " + salesOrderId);

        helper.getFieldResponses(cmp,salesOrderId);
        window.setTimeout(
            $A.getCallback(function (){
                let action = cmp.get("c.getBackOfficeFormData");
                action.setParams({
                    "salesOrderId" : salesOrderId
                });
                action.setCallback(this, function (response){
                    let state = response.getState();
                    let form = response.getReturnValue();
                    if (state === "SUCCESS") {
                        if (form) {
                            console.log('selected form: ' + JSON.stringify(form));
                            cmp.set("v.form", form.form);
                            cmp.set("v.formGroups", form.fieldGroups);
                            cmp.set("v.formFields", form.fields);
                            cmp.set("v.contactId", form.contactId);
                            cmp.set("v.formResponse", form.formResponse);
                            cmp.set("v.isLoading", false);

                        } else {
                            cmp.set("v.formExists", false);
                            cmp.set("v.isLoading", false);
                        }
                    }else{
                        let error = response.getError();
                        console.log(error.message);
                    }

                });
                $A.enqueueAction(action);
            }),3000);

    },

    /**
     * @purpose FormFields cmp calls ValidateEvt and passes the field Id and isValid indication.
     *          Once it is validated, it is added to a validated list. Page does not move on until the number of
     *          fields in the form matches the number of validated fields. 
     * @param cmp
     * @param event
     * @param helper
     */

    handleValidate : function(cmp, event, helper){

        console.log("validateFields function firing from BackOfficeForm.js");
        let isValid = event.getParam("isValid");
        let fieldId = event.getParam("fieldId");
        let allValid = cmp.get('v.validationCheck');

        if (isValid === true && !allValid.includes(fieldId)) {
            console.log('fieldID = ' + fieldId);
            allValid.push(fieldId);
            cmp.set('v.validationCheck', allValid);
        }
            console.log("allValid = " + allValid);

        if((allValid && allValid.length === cmp.get("v.formFields").length) || fieldId == 'No Form'){

            const stepId = event.getParam("stepId");
            const cmpName = event.getParam("cmpName");

            let navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": stepId});
            navEvt.setParams({"cmpName": cmpName});
            navEvt.fire();
        }else {
            let navEvt = $A.get("e.c:JP_NavigateEvt");
            navEvt.setParams({"stepId": cmp.get("v.stepId")});
            navEvt.setParams({"cmpName": null});
            navEvt.fire();
        }

    },

});