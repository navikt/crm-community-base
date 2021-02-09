import { LightningElement, track } from 'lwc';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class HeaderSearchButton extends LightningElement {
    @track searchPressed = false;
    @track searchWord = '';
    @track url;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    handleOnClickSearch(event) {
        this.searchPressed = !this.searchPressed;
    }

    handleSearch(event) {
        this.searchWord = event.target.value;
    }
    searchNav() {
        this.url = 'https://www.nav.no/sok?ord=' + this.searchWord;
        window.location = this.url;
    }
}
