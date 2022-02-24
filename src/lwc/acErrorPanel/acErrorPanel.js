/**
 * Created by mitfity on 24.07.2019.
 */

import { LightningElement, api, track } from 'lwc';
import { reduceErrors } from 'c/acUtils';
import msgErrorRetrievingData from '@salesforce/label/c.msgErrorRetrievingData';

export default class AcErrorPanel extends LightningElement {
    @api friendlyMessage = msgErrorRetrievingData;

    @track viewDetails = false;

    /** Single or array of LDS errors */
    @api errors;

    get errorMessages() {
        return reduceErrors(this.errors);
    }

    onCheckboxChange(event) {
        this.viewDetails = event.target.checked;
    }
}