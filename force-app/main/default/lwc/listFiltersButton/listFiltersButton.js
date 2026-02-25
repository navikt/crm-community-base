import { LightningElement, api } from 'lwc';

export default class ListFiltersButton extends LightningElement {
    @api header;
    @api activeFilters;
    @api filters;
    isOpen = false;

    connectedCallback() {
        document.documentElement.style.setProperty('--filterButtonColor', '#262626');
        document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#ffffffff');
        document.documentElement.style.setProperty('--filterButtonBorderColor', '#6D7786');
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
            document.documentElement.style.setProperty('--filterButtonColor', '#262626');
            document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#6D7786');
        } else {
            document.documentElement.style.setProperty('--filterButtonColor', '#262626');
            document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#ffffffff');
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
