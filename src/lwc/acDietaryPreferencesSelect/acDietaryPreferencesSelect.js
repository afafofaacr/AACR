/**
 * Created by mitfity on 28.08.2019.
 */

import {LightningElement, api, track} from 'lwc';
import getFieldSetOptions from '@salesforce/apex/brEventDietaryPreferencesController.getFieldSetOptions';
import getSelectedFieldSetName from '@salesforce/apex/brEventDietaryPreferencesController.getSelectedFieldSetName';
import saveFieldSetName from '@salesforce/apex/brEventDietaryPreferencesController.saveFieldSetName';

export default class AcDietaryPreferencesSelect extends LightningElement {
    @api recordId;

    @track __isLoading = false;
    @track error;
    @track fieldSetOptions;
    @track selectedFieldSet;

    set isLoading(value) {
        if (!!value) {
            this.error = false;
        }

        this.__isLoading = value;
    }

    get isLoading() {
        return this.__isLoading;
    }

    connectedCallback() {
        const { recordId } = this;

        this.isLoading = true;
        console.log('recordId : ' + recordId);
        getSelectedFieldSetName({
            eventId: recordId

        }).then(fieldSetName => {
            this.selectedFieldSet = fieldSetName;
            console.log('selectedFieldSet: ' + fieldSetName);

            return getFieldSetOptions();
        }).then(fieldSetOptions => {
            this.fieldSetOptions = fieldSetOptions;
            console.log('fieldSetOptions: ' + fieldSetOptions);
        }).catch(reason => {
            console.log('error: ' + reason);
            this.error = reason;
        }).finally(() => {
            this.isLoading = false;
        })
    }

    onSaveClick() {
        const { recordId, selectedFieldSet } = this;

        this.isLoading = true;
        saveFieldSetName({
            eventId: recordId,
            fieldSetName: selectedFieldSet
        }).then(() => {
        }).catch(reason => {
            this.error = reason;
        }).finally(() => {
            this.isLoading = false;
        })
    }

    onChange(event) {
        console.log('event.detail.value: ' + event.detail.value);

        this.selectedFieldSet = event.detail.value;
    }
}