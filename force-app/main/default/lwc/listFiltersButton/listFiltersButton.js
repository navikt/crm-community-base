import { LightningElement, api } from 'lwc';

export default class ListFiltersButton extends LightningElement {
    @api header;
    @api activeFilters;
    @api filters;
    isOpen = false;

    connectedCallback() {
        document.documentElement.style.setProperty('--filterButtonColor', '#262626');
        document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#ffffff');
        document.documentElement.style.setProperty('--filterButtonBorderColor', '#5D6574');
    }

    openFilters() {
        this.isOpen = !this.isOpen;
        this.buttonStyling();
        this.template.querySelector('c-list-filters').openFilters();
    }

    buttonStyling() {
        if (window.screen.width < 576) {
            return; // Don't need styling on mobile - got overlay
        }
        if (this.isOpen) {
            document.documentElement.style.setProperty('--filterButtonColor', '#ffffff');
            document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#E0E3E7');
        } else {
            document.documentElement.style.setProperty('--filterButtonColor', '#262626');
            document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#ffffff');
        }
    }

    applyFilter(event) {
        this.isOpen = !this.isOpen;
        this.buttonStyling();
        const eventToSend = new CustomEvent('applyfilter', { detail: event.detail });
        this.dispatchEvent(eventToSend);
    }

    getFilteredRecordsLength(event) {
        const eventToSend = new CustomEvent('getfilteredrecordslength', { detail: event.detail });
        this.dispatchEvent(eventToSend);
    }

    @api setFilteredRecordsLength(filteredRecordsLength) {
        this.template.querySelector('c-list-filters').setFilteredRecordsLength(filteredRecordsLength);
    }
}
