import { LightningElement, wire } from 'lwc';
import globalModalOpen from '@salesforce/messageChannel/globalModalOpen__c';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';

export default class ContextInterface extends LightningElement {
    hiddenSR = false;

    @wire(MessageContext)
    messageContext;

    addModalContext() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, globalModalOpen, (message) =>
                this.handleModalChannel(message)
            );
        }
    }

    removeModalContext() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleModalChannel = (event) => {
        this.hiddenSR = event.status;
    };
}
