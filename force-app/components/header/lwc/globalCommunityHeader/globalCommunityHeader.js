import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';

export default class GlobalCommunityHeader extends LightningElement {
    @api NAVarea;

    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    connectedCallback() {
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';
    }
}
