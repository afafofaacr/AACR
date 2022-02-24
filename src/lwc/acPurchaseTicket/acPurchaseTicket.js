/**
 * Created by mitfity on 19.07.2019.
 */

import {LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorMessage, getUrlParams } from 'c/acUtils';
import getTicketPurchaseUrl from '@salesforce/apex/brPurchaseTicketController.getTicketPurchaseUrl';
import sendRefundRequest from '@salesforce/apex/brPurchaseTicketController.sendRefundRequest';
import checkForTickets from '@salesforce/apex/brPurchaseTicketController.checkForTicket';
import registerForCoupledEvent from '@salesforce/apex/brPurchaseTicketController.registerForCoupledEvent';
import completePurchase from '@salesforce/apex/brPurchaseTicketController.completePurchase';

export default class AcPurchaseTicket extends LightningElement {
    @api eventId;
    @api event;
    @track showButton;
    @track isLoading = false;
    @track refundRequestSent = false;
    @track modalOpen = false;
    @track toastOpen = false;
    @track refundsOpen = false;
    @track childRegisterFailure =false;
    @track awaitingPayment = false;
    @track awaitingApproval = false;
    @track showRegister;



    registerForParent(){
        const eventId = this.event.item.Parent_Event__c;
        this.isLoading = true;
        getTicketPurchaseUrl({
            eventId
        }).then(purchaseUrl => {
            console.log('purchaseURL: ' + purchaseUrl);
            // window.location.href = purchaseUrl;
            window.open(purchaseUrl, '_blank');
            this.isLoading = false;
            this.childRegisterFailure = false;
        }).catch(reason => {
            this.dispatchEvent(new ShowToastEvent({
                title: "Error",
                message: getErrorMessage(reason),
                variant: "warning"
            }));
            this.isLoading = false;
        }).finally(() => {
        });
    }


    onPurchaseClick() {
        const { eventId } = this;


       console.log('parent: ' + this.event.item.Parent_Event__c);

        console.log('onPurchaseClick...' + eventId);
        if(this.event.item.Parent_Event__c==null) {
            this.isLoading = true;
            getTicketPurchaseUrl({
                eventId
            }).then(purchaseUrl => {
                console.log('purchaseURL: ' + purchaseUrl);
                window.location.href = purchaseUrl;
            }).catch(reason => {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: getErrorMessage(reason),
                    variant: "warning"
                }));
                this.isLoading = false;
            }).finally(() => {
            });
        } else {
            console.log('this event has a parent...begin alternate sequence of events');
            registerForCoupledEvent({
                eventId
            }).then(result => {
                console.log('result: ' + result);
                if(result ==false){
                    console.log('error');
                    this.childRegisterFailure = true;
                } else {
                    window.location.reload();
                }
            }).catch(reason => {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: getErrorMessage(reason),
                    variant: "warning"
                }));
                this.isLoading = false;
            }).finally(() => {
            });
        }
    }

    openModal(){
        this.modalOpen = true;
    }

    closeModal(){
        this.modalOpen = false;
        this.childRegisterFailure = false;
    }

    closeAlert(){
        this.toastOpen = false;
    }

    requestRefund(){
        console.log('requestRefund...');

        const { eventId } = this;

        var today = new Date().toLocaleString("en-US", {timeZone: "America/New_York"});
        var eventStart = new Date(this.event.item.Start_Date__c);
        eventStart = eventStart.toLocaleString("en-US", {timeZone: "America/New_York"});
        if(eventStart<=today){
            window.location.reload();
        } else {

            this.isLoading = true;
            sendRefundRequest({
                eventId
            }).then(success => {
                console.log('success: ' + success);
                // alert('SUCCESS!');
                this.modalOpen = false;
                this.toastOpen = true;
                this.refundRequestSent = true;
                this.isLoading = false;
                const refundRequestEvent = new CustomEvent('refundrequest', {
                    detail: {},
                });
                // Fire the custom event
                this.dispatchEvent(refundRequestEvent);
            }).catch(reason => {
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: getErrorMessage(reason),
                    variant: "warning"
                }));
                this.isLoading = false;
            }).finally(() => {
            });
        }

    }

    finishPurchase(){
        var eventId = this.eventId;
        completePurchase({
            eventId
        }).then(purchaseUrl => {
            console.log('purchaseURL: ' + purchaseUrl);
            window.location.href = purchaseUrl;
        }).catch(reason => {
            this.dispatchEvent(new ShowToastEvent({
                title: "Error",
                message: getErrorMessage(reason),
                variant: "warning"
            }));
            this.isLoading = false;
        }).finally(() => {
        });
    }

    connectedCallback() {

        var eventId = this.eventId;

        this.showRegister = !this.event.userIsParticipating;

        checkForTickets({
            eventId
        }).then(response => {
            console.log('response: ' + JSON.stringify(response));
            if(response!=null) {
                if (response.Participate__c == 'Pending Approval') {
                    this.awaitingApproval = true;
                    this.showRegister = false;
                }
                if (response.Participate__c == 'Awaiting Payment') {
                    this.awaitingPayment = true;
                    this.showRegister = false;
                }
                this.refundRequestSent = response.Refund_Requested__c;
            }

            this.showButton = true;

            var eventStart = new Date(this.event.item.Start_Date__c);
            var today = new Date();

            this.refundsOpen = (today<=eventStart && this.event.item.Refunds_Open__c);

        }).catch(reason => {
            console.log('reason: ' + reason);
            this.dispatchEvent(new ShowToastEvent({
                title: "Error",
                message: getErrorMessage(reason),
                variant: "warning"
            }));
            this.isLoading = false;
        }).finally(() => {
        });

    }
}