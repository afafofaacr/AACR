/**
 * Created by mitfity on 03.09.2019.
 */

import {LightningElement, api, track} from 'lwc';
import btnPublish from '@salesforce/label/c.btnPublish';
import btnDraft from '@salesforce/label/c.btnDraft';
import publishEvent from '@salesforce/apex/BrEventsItemController.publishEvent';
import draftEvent from '@salesforce/apex/BrEventsItemController.draftEvent';
import getEvent from '@salesforce/apex/BrEventsItemController.getEvent';

export default class BrEventPreviewActions extends LightningElement {
    @api eventId;
    @track __isLoading = false;
    @track error;
    @track event;
    @track dataLoaded = false;

    labels = {
        btnPublish, btnDraft
    };

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
        this.isLoading = true;

        getEvent({
            recordId: this.eventId
        }).then(event => {
            this.event = event;
            this.dataLoaded = true;
        }).catch(reason => {
            this.error = reason;
        }).finally(() => {
            this.isLoading = false;
        });
    }

    onPublishClick() {
        const { eventId } = this;

        this.isLoading = true;

        publishEvent({
            eventId
        }).then(() => {
            this.event.item.Draft__c = false;
        }).catch(reason => {
            this.error = reason;
        }).finally(() => {
            this.isLoading = false;
        });
    }

    onDraftClick() {
        const { eventId } = this;

        this.isLoading = true;

        draftEvent({
            eventId
        }).then(() => {
            this.event.item.Draft__c = true;
        }).catch(reason => {
            this.error = reason;
        }).finally(() => {
            this.isLoading = false;
        });
    }
}