/**
 * @author          :  CRM Science, Inc.
 * @date            :  10/7/2020
 * @description     :  This component validates the offer code inputted
 */
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOffers from '@salesforce/apex/MembershipCodeGenerator.getOffers';
import generateMemberships from '@salesforce/apex/MembershipCodeGenerator.generateMemberships';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OFFER_VERSION_OBJECT from '@salesforce/schema/OfferVersion__c';

export default class MembershipCodeGenerator extends LightningElement {

    @track formData = {};
    @track validData;
    offers = [];
    
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

    // get fields info for the help text
    @track fieldsInfo;
    /**
     * @description : Used to retrieve the help text for the fields
     */
    @wire(getObjectInfo, { objectApiName: OFFER_VERSION_OBJECT })
    getAccountInfo(result) {
        if (result.data)
            this.fieldsInfo = result.data.fields;
        console.log(JSON.stringify(result));
    }
    

    /**
     * @description : Used to retrieve the Offer records to display in a dropdown
     */
    @wire(getOffers)
    getOffersWire(response) {        
        const { error, data } = response;
        
        if(error) {
            console.log('error: ' + JSON.stringify(error, null, '\t'));

        } else if (data) {
                        
            // work with local array first
            let offers = [];

            // populate offers with label, value list
            data.forEach(element => {
                // Build a new row in our this.offers
                let offerObj = {label: element.Name, value: element.Id};
                offers.push(offerObj);
            });

            // Salesforce will only rerender on changed elements with = but does not consider array.push to be an assignment
            this.offers = offers;
        }
    }

    /**
     * @description : Gets the input when it changes and sets it according to field
     * @param {String} event - The onchange event that occurs
     */
    handleInputChange(event) {
        console.log('===handleInputChange===');
        
        // Which field is this for?
        const field = event.target.dataset.field; // AKA data-field= on html side
        console.log('we are using this field: ' + field);
        const type = event.target.dataset.type; // AKA data-type= on html side
        console.log('we are using this type: ' + type);
        const value = type == 'checkbox' ? event.target.checked : event.target.value;
        console.log('we are using this value: ' + value);

        // dynamically assign value to new property
        this.formData[field] = value;
    }
 
    /**
     * @description : Gets the offer selected
     * @param {String} event - The onchange event that occurs
     */
    handleOfferChange(event) {
        console.log(event.detail.value);

        this.formData.selectedOffer = event.detail.value;
    }

    /**
     * @description : Called from the Create button, uses Apex method to create OfferVersion and OfferMemberships
     */
    handleCreateClick() {
        
        this.formData.override = this.formData.override == null ? false : this.formData.override;
        this.formData.publish = this.formData.publish == null ? false : this.formData.publish;

        if (this.formData.selectedOffer == null || this.formData.versionCode == null || this.formData.soqlString == null) {
            // required fields are empty           
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error ',
                    message: 'Please fill in required fields',
                    variant: 'error'
                })
            );

        } else {
            // Fire the process to create the offer version
            this.showSpinner(".form-spinner");

            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                generateMemberships({offerId: this.formData.selectedOffer, startDate: this.formData.startDate, endDate: this.formData.endDate, oRide: this.formData.override, publish: this.formData.publish, soqlString: this.formData.soqlString, description: this.formData.description, versionCode: this.formData.versionCode})
                .then(result => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!',
                            message: result,
                            variant: 'success'
                        }),
                    );

                    // reset the form fields
                    let formData = JSON.parse(JSON.stringify(this.formData));
                    for (const key in formData) {
                        if (formData.hasOwnProperty(key)) {
                            formData[key] = null;
                        }
                    }
                    this.formData = formData;
                })
                .catch(error => {
                    console.log('createMemberships error: ' + error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating Offer Membership(s)',
                            message: JSON.stringify(this.findNested(error, ['message', 'stackTrace'])),
                            variant: 'error'
                        }),
                    );
                })
                .finally(() => {
                    this.hideSpinner(200, '.form-spinner');
                })
            }, 10);    
        }

        
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