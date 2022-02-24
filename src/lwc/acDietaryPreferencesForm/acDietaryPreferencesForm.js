/**
 * Created by mitfity on 25.07.2019.
 */

import {LightningElement, api, track} from 'lwc';
import getEventPreferencesFormFields from '@salesforce/apex/brPurchaseTicketController.getEventPreferencesFormFields';
import { getUrlParams } from 'c/acUtils';

export default class AcDietaryPreferencesForm extends LightningElement {
    @track isLoading = false;
    @track fields;
    @track error;
    @track participationId;
    @track eventId;
    @track userId;
    @track contactId;
    @track salesOrderId;
    @track noFormRequired = false;
    dataLoaded = false;


    /**
     * Saves event preferences.
     * @returns {Promise}
     */
    @api
    save() {
        this.error = null;
        this.template.querySelector('lightning-record-edit-form').submit();

    }

    handleSuccess(){
        const formSaveEvt = new CustomEvent('formSaved', {
            detail: {status: 'success'}
        });
        this.dispatchEvent(formSaveEvt);

    }

    handleError(event){
        const formSaveEvt = new CustomEvent('formSaved', {
            detail: {status: 'error'}
        });
        this.dispatchEvent(formSaveEvt);

    }


    connectedCallback() {
        // console.log('getURLParams: ' + JSON.stringify(getUrlParams()));
        const { c__salesOrder } = getUrlParams();
        const { salesOrder } = getUrlParams();

        this.salesOrderId = c__salesOrder!=null?c__salesOrder:salesOrder;

        var soId = this.salesOrderId;
        this.isLoading = true;

        getEventPreferencesFormFields({
            salesOrderId : soId
        }).then(fields => {
            console.log("fields: " + JSON.stringify(fields));
                this.fields = fields.fields;
                this.participationId = fields.participationId;
                this.userId = fields.userId;
                this.contactId = fields.contactId;
                this.eventId = fields.eventId;
            if(fields.fields==null) {
                this.noFormRequired = true;
            }


            this.dataLoaded = true;
        }).catch(reason => {
            this.error = reason;
        }).finally(() => {
            this.isLoading = false;
        });
    }
}