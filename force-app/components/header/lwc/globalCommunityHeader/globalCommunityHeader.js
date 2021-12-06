import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import dist from '@salesforce/resourceUrl/dist';

export default class GlobalCommunityHeader extends LightningElement {
    @api NAVarea;
    @api navareapicklist;

    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    renderedCallback() {
        loadStyle(this, dekoratoren);
        loadStyle(this, dist);
    }

    connectedCallback() {
        // The new LWR template doesn't support properties with uppercase first character ¯\_(ツ)_/¯
        this.NAVarea = this.NAVarea ?? this.navareapicklist;
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';
    }
}
