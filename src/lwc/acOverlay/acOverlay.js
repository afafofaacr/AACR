/**
 * Created by mitfity on 19.07.2019.
 */

import {LightningElement, api} from 'lwc';

export default class AcOverlay extends LightningElement {
    @api overlayIndicator = false;
    @api label = '';

    get containerClass() {
        return `slds-grid slds-grid--align-center ${this.overlayIndicator ? '' : ' slds-hide'}`;
    }
}