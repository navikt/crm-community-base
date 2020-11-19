import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';

export default class HeaderDropdownMenu extends LightningElement {
    @track menuPressed = false;

    @track isPrivatperson;
    @track isArbeidsgiver = true;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    handleOnClickMenu(event) {
        this.menuPressed = !this.menuPressed;
    }
}