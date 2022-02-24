/**
 * Created by mitfity on 31.07.2019.
 */

import {LightningElement, api, track} from 'lwc';
import msgWhenValueMissing from '@salesforce/label/c.msgWhenValueMissing';

export default class AcInputRichText extends LightningElement {
    @api label;
    @api required = false;
    @api placeholder;
    @api maxLength = 32000;
    @api messageWhenValueMissing = msgWhenValueMissing;
    @track errorMessage;
    @track isValid = true;

    @api
    get value() {
        const editor = this.template.querySelector('lightning-input-rich-text');

        return editor.value;
    }

    onBlur() {
        this.validate();
    }

    /**
     * Validates input and returns validity state.
     */
    validate() {
        const { value, required, messageWhenValueMissing } = this;
        let { maxLength } = this;
        let isValid = true;

        maxLength = parseInt(maxLength, 10);

        if (required && this.valueMissing(value)) {
            isValid = false;
            this.errorMessage = messageWhenValueMissing;
        }

        if (value && value.length > maxLength) {
            isValid = false;
            this.errorMessage = 'Value cannot exceed ' + maxLength + ' symbols.';
        }

        this.isValid = isValid;

        return isValid;
    }

    /**
     * Displays the error messages and returns false if the input is invalid. If the input is valid, reportValidity()
     * clears displayed error messages and returns true.
     * @returns {boolean}
     */
    @api
    reportValidity() {
        const editor = this.template.querySelector('lightning-input-rich-text');

        editor.focus();
        editor.blur();

        return this.isValid;
    }

    /**
     * Determines if value is missing.
     * @returns {boolean} true if value is missing
     */
    valueMissing(value) {
        if (value) {
            value = value.replace(/<(?:.|\n)*?>/gm, '');
            value = value.trim();
        }

        return !value;
    }
}