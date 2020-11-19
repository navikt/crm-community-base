import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';

export default class HeaderDropdownMenu extends LightningElement {
    @track menuPressed = false;
    @api area;

    @track isPrivatperson;
    @track isArbeidsgiver;
    @track isSamarbeidspartner;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }
    
    connectedCallback() {
        console.log('pressed', this.pressed);
        this.isPrivatperson = this.area == 'Privatperson';
        this.isArbeidsgiver = this.area == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.area == 'Samarbeidspartner';
    }

    handleOnClickMenu(event) {
        this.menuPressed = !this.menuPressed;
    }
}