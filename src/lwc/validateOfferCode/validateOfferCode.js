/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This component validates the offer code inputted
 */
import { LightningElement, api} from 'lwc';
import codeConfirm from '@salesforce/apex/ValidateOfferCode.codeConfirm';
import getOfferCode from '@salesforce/apex/ValidateOfferCode.getOfferCode';

export default class ValidateOfferCode extends LightningElement {

    currentPageReference;
    SOId;
    code;
    usedMode;
    successMessage;
    appliedMessage;
    error;
    connectedCallbackRan = false;


    @api get salesOrderId(){
        return this.SOId;
    }

    set salesOrderId(value){
        this.SOId = value;
        this.handleSOValueChange(value);
    }

    handleSOValueChange(value) {
        console.log(value);
        //do something

        console.log('salesOrderId: ' + this.SOId);
        if(this.SOId!=null && value!=null ) {
            getOfferCode({salesOrderId: this.SOId})
                .then(result => {
                    console.log('result: ' + result);
                    if (result != null) {
                        this.code = result;
                        this.successMessage = 'Success!';
                        this.error = null;
                        this.appliedMessage = 'Offer Applied';
                    }
                })
                .catch(error => {
                    // show error in successMessage
                    this.error = 'Error';
                    // console.log('Validation error: ' + JSON.stringify(this.findNested(error, ['message', 'stackTrace'])));

                    this.successMessage = null;
                }).finally(() => {
                this.hideSpinner(200, '.form-spinner');
            });
        }
    }

    // Spinner methods
    /**
     * @description : Retrieves the spinner component
     * @param {String} selector - retrieves the spinner component
     */
    getSpinner(selector) {
        selector = !selector ? 'c-csi-spinner' : selector;
        return this.template.querySelector(selector);
    }
    /**
     * @description : Shows the spinner
     * @param {String} selector - retrieves the spinner component
     */
    showSpinner(selector){
        let spinner = this.getSpinner(selector);
        if (spinner) spinner.showSpinner();
    }
    /**
     * @description : Hides the spinner
     * @param {String} selector - retrieves the spinner component
     */
    hideSpinner(len, selector){
        let spinner = this.getSpinner(selector);
        if (spinner) spinner.hideSpinner(len);
    }




    /**
     * @description : Runs on load
     */
    connectedCallback(){
        console.log('connectedcallback');
        if (this.connectedCallbackRan) return;
        this.connectedCallbackRan = true;

        let parameters = this.getQueryParameters();
        console.log('parameters: ' + JSON.stringify(parameters));

        if(parameters && parameters.c__OfferCode && parameters.c__OfferCode.length > 2) {
            this.code = parameters.c__OfferCode;
            console.log('Code from url: ' + this.code);

            this.usedMode = 'URL';
            this.validateCode();
        }

    }

    /**
     * @description : Sets this.code equal to the input
     * @param {String} event - The onchange event that occurs
     */
    handleInputChange(event) {
        console.log('changed val: ' + event.target.value);
        this.code = event.target.value;
    }

    /**
     * @description : Called on click of Confirm button, sets usedMode and calls validateCode() method
     */
    handleConfirmClick() {
        this.usedMode = 'Manual';
        this.validateCode();
    }

    // utility methods
    // =================================

    /**
     * @description : Calls Apex method to validate the entered code
     */
    validateCode(){
        console.log('validateCode');
        // validate the code exists
        if (this.code == null || this.code.length <= 4) {
            console.log('error');
            this.error = 'Error: Please enter code to confirm.'
        } else {
            // show spinner
            this.showSpinner(".form-spinner");

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                // call the imperative code check
                codeConfirm({offerCode: this.code, usedMode: this.usedMode, salesOrderId: this.SOId})
                    .then(result => {
                        console.log('result: ' + result);
                        // Does the result have an error?
                        if (result.HasError == true) {
                            this.successMessage = null;
                            this.error = result.ErrorMsg;
                            // Fire event with wrapper object in result
                            this.dispatchEvent(
                                new CustomEvent("codeerror", {
                                    detail: {
                                        sourceCodeId: '',
                                        result: false,
                                        membershipId: '',
                                        usedMode: '',
                                        errorMsg : result.ErrorMsg
                                    }
                                })
                            );
                        } else {
                            this.successMessage = 'Success!';
                            this.error = null;
                            this.appliedMessage = 'Offer Applied';

                            // Fire event with wrapper object in result
                            this.dispatchEvent(
                                new CustomEvent("codesuccess", {
                                    detail: {
                                        sourceCodeId: result.SourceCode,
                                        result: true,
                                        membershipId: result.MembershipId,
                                        usedMode: result.UsedMode,
                                        errorMsg : null
                                    }
                                })
                            );
                        }
                    })
                    .catch(error => {
                        // show error in successMessage
                        this.error = 'Error';
                        // console.log('Validation error: ' + JSON.stringify(this.findNested(error, ['message', 'stackTrace'])));

                        this.successMessage = null;
                    }).finally(() => {
                    this.hideSpinner(200, '.form-spinner');
                });
            }, 10);
        }
    }

    /**
     * @description : run in connectedCallback() to get the parameters needed for the query in Apex
     */
    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

    // Method that will find any "message" in the Apex errors that come back after insert attempts
    // Could be a validation rule, or duplicate record, or pagemessage.. who knows!
    // Use in your next error toast from a wire or imperative catch path!
    // message: JSON.stringify(this.findNested(error, ['message', 'stackTrace'])),
    // Testing multiple keys: this.findNested({thing: 0, list: [{message: 'm'}, {stackTrace: 'st'}], message: 'm2'}, ['message', 'stackTrace'])
    /**
     * @description : Method that will find any "message" in the Apex errors that come back after insert attempts
     */
    findNested(obj, keys, memo) {
        let i,
            proto = Object.prototype,
            ts = proto.toString,
            hasOwn = proto.hasOwnProperty.bind(obj);

        if ('[object Array]' !== ts.call(memo)) memo = [];

        for (i in obj) {
            if (hasOwn(i)) {
                if (keys.includes(i)) {
                    memo.push(obj[i]);
                } else if ('[object Array]' === ts.call(obj[i]) || '[object Object]' === ts.call(obj[i])) {
                    this.findNested(obj[i], keys, memo);
                }
            }
        }

        return memo.length == 0 ? null : memo;
    }
}