import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';

export default class GlobalCommunityHeader extends LightningElement {
    @api NAVarea;
    @api navareapicklist;

    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    connectedCallback() {
        // The new LWR template doesn't support properties with uppercase first character ¯\_(ツ)_/¯
        console.log(this.NAVarea);
        console.log(this.navareapicklist);
        console.log(this.NAVarea ?? this.navareapicklist);
        this.NAVarea = this.NAVarea ?? this.navareapicklist;
        console.log("Hallo");
        
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';
    }
}
