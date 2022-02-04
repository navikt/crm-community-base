import { track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';

import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import icons from '@salesforce/resourceUrl/icons';
import logos from '@salesforce/resourceUrl/logos';

import ContextInterface from 'c/contextInterface';

export default class GlobalCommunityFooter extends ContextInterface {
    arrowupicon = icons + '/arrowupicon.svg';
    logosvart = logos + '/navLogoBlack.svg';
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
        this.NAVarea = this.NAVarea ?? this.navareapicklist;

        this.isPrivatperson = this.navareapicklist == 'Privatperson';
        this.isArbeidsgiver = this.navareapicklist == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.navareapicklist == 'Samarbeidspartner';

        this.addModalContext();
    }

    disconnectedCallback() {
        this.removeModalContext;
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
