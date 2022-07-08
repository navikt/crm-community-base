import { track, api } from 'lwc';
// import { loadStyle } from 'lightning/platformResourceLoader';
// import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
// import index from '@salesforce/resourceUrl/index';

import ContextInterface from 'c/contextInterface';

export default class GlobalCommunityHeader extends ContextInterface {
    @api NAVarea;
    @api navareapicklist;

    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    renderedCallback() {
        // loadStyle(this, dekoratoren);
        // loadStyle(this, index);
    }

    connectedCallback() {
        // The new LWR template doesn't support properties with uppercase first character ¯\_(ツ)_/¯
        this.NAVarea = this.NAVarea != null && this.NAVarea != undefined ? this.NAVarea : this.navareapicklist;
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';

        this.addModalContext();
    }

    disconnectedCallback() {
        this.removeModalContext();
    }
}
