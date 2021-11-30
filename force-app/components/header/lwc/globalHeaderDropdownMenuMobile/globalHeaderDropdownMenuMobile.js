import { LightningElement, track, api } from 'lwc';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class GlobalHeaderDropdownMenuMobile extends LightningElement {
    @api area;

    @track menuPressed = false;
    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;
    body;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    connectedCallback() {
        this.isPrivatperson = this.area == 'Privatperson';
        this.isArbeidsgiver = this.area == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.area == 'Samarbeidspartner';
        this.body = document.getElementsByTagName('body')[0];
    }

    handleOnClickMenu(event) {
        this.menuPressed = !this.menuPressed;
        this.body.classList.toggle('no-scroll-mobil');
    }
}
