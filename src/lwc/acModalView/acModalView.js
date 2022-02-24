/**
 * Created by mitfity on 24.07.2019.
 */

import { LightningElement, api, track } from 'lwc';
import labelClose from '@salesforce/label/c.labelClose';
import btnCancel from '@salesforce/label/c.btnCancel';

export default class AcModalView extends LightningElement {
    /**
     * Dialog title.
     */
    @api title;
    /**
     * Variant property of accept button.
     */
    @api acceptVariant = 'brand';
    /**
     * Label property of accept button.
     */
    @api acceptLabel;
    /**
     * Modal window error message.
     */
    @api error;

    @track lockButtons = false;

    labels = {
        labelClose,
        btnCancel
    };

    onCloseModalClicked() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    onAcceptClicked() {
        if (this.lockButtons) {
            return;
        }

        this.dispatchEvent(new CustomEvent('accept'));
    }

    /**
     * Toggles buttons lock state.
     * @param toggle
     */
    @api
    toggleButtonsLock(toggle) {
        if (toggle != null) {
            this.lockButtons = !!toggle;
            return;
        }

        this.lockButtons = !this.lockButtons;
    }
}