import { LightningElement, track, api } from 'lwc';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class HeaderDropdownMenuMobile extends LightningElement {
    @api area;

    @track menuPressed = false;
    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;


    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    connectedCallback() {
        this.isPrivatperson = this.area == 'Privatperson';
        this.isArbeidsgiver = this.area == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.area == 'Samarbeidspartner';
    }

    handleOnClickMenu(event) {
        this.menuPressed = !this.menuPressed;
    }
}