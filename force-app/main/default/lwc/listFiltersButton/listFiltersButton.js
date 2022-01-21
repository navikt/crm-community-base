import { LightningElement, api } from 'lwc';

export default class ListFiltersButton extends LightningElement {
    @api header;
    @api activeFilters;
    @api filters;
    isOpen = false;

    connectedCallback() {
        document.documentElement.style.setProperty('--filterButtonColor', '#262626');
        document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#EFEFEF');
        document.documentElement.style.setProperty('--filterButtonBorderColor', '#929292');
    }

    setFilterButtonColor() {
        if (this.isOpen) {
            document.documentElement.style.setProperty('--filterButtonColor', '#ffffff');
            document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#0056b4');
        } else {
            document.documentElement.style.setProperty('--filterButtonColor', '#262626');
            document.documentElement.style.setProperty('--filterButtonBackgroundColor', '#EFEFEF');
        }
    }

    openFilters() {
        this.isOpen = !this.isOpen;
        this.setFilterButtonColor();
        this.template.querySelector('c-list-filters').openFilters();
    }

    applyFilter(event) {
        this.isOpen = !this.isOpen;
        this.setFilterButtonColor();
        const eventToSend = new CustomEvent('applyfilter', { detail: event.detail });
        this.dispatchEvent(eventToSend);
    }
}
