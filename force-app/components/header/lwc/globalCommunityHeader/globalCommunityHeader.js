import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import index from '@salesforce/resourceUrl/index';

import globalModalOpen from '@salesforce/messageChannel/globalModalOpen__c';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';

export default class GlobalCommunityHeader extends LightningElement {
    @api NAVarea;
    @api navareapicklist;

    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;
    hiddenSR = false;

    @wire(MessageContext)
    messageContext;

    renderedCallback() {
        loadStyle(this, dekoratoren);
        loadStyle(this, index);
    }

    connectedCallback() {
        // The new LWR template doesn't support properties with uppercase first character ¯\_(ツ)_/¯
        this.NAVarea = this.NAVarea ?? this.navareapicklist;
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, globalModalOpen, (message) =>
                this.handleModalChannel(message)
            );
        }
    }

    disconnectedCallback() {
        this.unsubscribe(this.subscription);
    }

    handleModalChannel = (event) => {
        this.hiddenSR = event.status;
    };
}
