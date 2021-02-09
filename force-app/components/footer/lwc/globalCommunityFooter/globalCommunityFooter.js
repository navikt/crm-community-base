import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import icons from '@salesforce/resourceUrl/icons';
import logos from '@salesforce/resourceUrl/logos';

export default class GlobalCommunityFooter extends LightningElement {
    arrowupicon = icons + '/arrowupicon.svg';
    logosvart = logos + '/navLogoBlack.svg';
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

    scrollToTop() {
        window.scroll(0, 0, 'smooth');
    }

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
