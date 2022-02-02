import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import icons from '@salesforce/resourceUrl/icons';
import logos from '@salesforce/resourceUrl/logos';

import globalModalOpen from '@salesforce/messageChannel/globalModalOpen__c';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';

export default class GlobalCommunityFooter extends LightningElement {
    arrowupicon = icons + '/arrowupicon.svg';
    logosvart = logos + '/navLogoBlack.svg';
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
    }

    connectedCallback() {
        // The new LWR template doesn't support properties with uppercase first character ¯\_(ツ)_/¯
        this.NAVarea = this.NAVarea ?? this.navareapicklist;

        this.isPrivatperson = this.navareapicklist == 'Privatperson';
        this.isArbeidsgiver = this.navareapicklist == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.navareapicklist == 'Samarbeidspartner';
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, globalModalOpen, (message) =>
                this.handleModalChannel(message)
            );
        }
    }

    disconnectedCallback() {
        this.unsubscribe(this.subscription);
    }

    scrollToTop() {
        window.scroll(0, 0, 'smooth');
    }

    handleModalChannel = (event) => {
        this.hiddenSR = event.status;
    };

    /* DEL SKJERM FUNKSJONER */
    /* @track isDelSkjerm = false;
    onHandleClickDelSkjerm() {
        this.isDelSkjerm = !this.isDelSkjerm;
    }

    @track isSkjermdelingLesMer = false;
    onHandleClickSkjermdelingInfo() {
        this.isSkjermdelingLesMer = !this.isSkjermdelingLesMer;
    }

    functionalityNotSupported() {
        alert("Vi støtter dessverre ikke denne funksjonaliteten i dag.");
    }*/
    /******************************************/
}
