import { LightningElement, api, track } from 'lwc';

export default class ListFilters extends LightningElement {
    @api header;
    @api activeFilters;
    @api filters;
    @track filterArray = [];

    connectedCallback() {
        let arr = [];
        this.filters.forEach((element) => {
            let temp = { ...element };
            temp.value = [];
            element.value.forEach((val) => {
                let value = { ...val };
                if (value.name !== 'All records') {
                    temp.value.push(value);
                }
            });
            arr.push(temp);
        });
        this.filterArray = arr;
    }

    isOpen = false;
    @api
    openFilters() {
        this.isOpen = !this.isOpen;
    }

    applyFilter() {
        const eventToSend = new CustomEvent('applyfilter', {
            detail: { filterArray: this.filterArray, setRecords: true }
        });
        this.dispatchEvent(eventToSend);
        this.closeFilters();
    }

    handleRowClick(event) {
        let filterindex = event.currentTarget.dataset.filterindex;
        this.filterArray[filterindex].isOpen = !this.filterArray[filterindex].isOpen;
    }

    handleCheckboxChange(event) {
        let filterindex = event.currentTarget.dataset.filterindex;
        event.detail.forEach((element, index) => {
            this.filterArray[filterindex].value[index].value = element.checked;
            this.filterArray[filterindex].value[index].checked = element.checked;
        });
        this.getFilteredRecordsLength();
    }

    handleDateChange(event) {
        let filterindex = event.currentTarget.dataset.filterindex;
        let valueindex = event.currentTarget.dataset.valueindex;
        let localTimeValue = this.template.querySelectorAll('c-input')[valueindex].getValue();
        localTimeValue = new Date(localTimeValue).toLocaleString();
        localTimeValue = localTimeValue.substring(0, localTimeValue.length - 10);
        this.filterArray[filterindex].value[valueindex].localTimeValue = localTimeValue;
        this.filterArray[filterindex].value[valueindex].value = event.detail;
        this.getFilteredRecordsLength();
    }

    removeFilter(event) {
        event.stopPropagation();
        let filterindex = event.currentTarget.dataset.filterindex;
        let valueindex = event.currentTarget.dataset.valueindex;
        this.filterArray[filterindex].value[valueindex].value = false;
        this.getFilteredRecordsLength();
    }

    overlayContainerClick(event) {
        event.stopPropagation();
    }

    overlayClick() {
        this.closeFilters();
    }
    closeFilters() {
        this.isOpen = false;
    }

    getFilteredRecordsLength() {
        let detail = { filterArray: this.filterArray, setRecords: false };
        const eventToSend = new CustomEvent('getfilteredrecordslength', { detail: detail });
        this.dispatchEvent(eventToSend);
    }

    buttonLabel = 'Vis treff';
    @api setFilteredRecordsLength(filteredRecordsLength) {
        this.buttonLabel = 'Vis ' + filteredRecordsLength + ' treff';
    }
}
