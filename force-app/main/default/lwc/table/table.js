import { LightningElement, api } from 'lwc';

export default class Table extends LightningElement {
    @api columns;
    @api records;
    @api iconByValue;
    @api hideMobileHeader;
    @api checkbox = false;
    @api startDateField = 'StartDate';
    @api endDateField = 'EndDate';

    get mobileHeaderStyle() {
        return this.hideMobileHeader && window.screen.width < 576 ? 'position: absolute; left: -10000px;' : '';
    }

    recordMap = {};
    get recordsToShow() {
        let records = [];
        if (this.records !== undefined && this.records !== null) {
            for (let record of this.records) {
                let fields = [];
                for (let column of this.columns) {
                    let field = {
                        name: column.name
                    };
                    field.value = this.getValue(record, column);
                    if (column.svg !== undefined && this.iconByValue[record[column.name]] !== undefined) {
                        field.svg = this.iconByValue[record[column.name]];
                    }
                    fields.push(field);
                }
                records.push({
                    id: record.Id,
                    fields: fields
                });
                this.recordMap[record.Id] = record;
            }
        }
        return records;
    }

    getValue(record, column) {
        if (column.name === 'StartAndEndDate') {
            let startDate = this.setDateFormat(record[this.startDateField]);
            let endDate = this.setDateFormat(record[this.endDateField]);
            let startDateSplit = startDate.split(',');
            let endDateSplit = endDate.split(',');
            if (startDateSplit[0] === endDateSplit[0]) {
                return startDate + ' - ' + endDateSplit[1];
            }
            return startDate + ' - ' + endDate;
        }
        let value = record[column.name];
        return value;
    }

    setDateFormat(value) {
        value = new Date(value);
        value = value.toLocaleString();
        value = value.substring(0, value.length - 3);
        return value;
    }

    handleOnRowClick(event) {
        const eventToSend = new CustomEvent('rowclick', { detail: this.recordMap[event.currentTarget.dataset.id] });
        this.dispatchEvent(eventToSend);
    }

    checkedRows = [];
    @api getCheckedRows() {
        return this.checkedRows;
    }

    @api unsetCheckboxes() {
        this.template.querySelectorAll('c-checkbox').forEach((element) => {
            element.clearCheckboxValue();
        });
    }

    handleSingleCheckboxClick() {
        let recordIdArray = this.resetRecordIdArray();
        this.template.querySelectorAll('c-checkbox').forEach((element, index) => {
            if (element.getValue()) {
                recordIdArray[index - 1].checked = true; // Index-1 to account for the first checkbox in header
            }
        });
        recordIdArray.forEach((element) => {
            if (element.checked) {
                this.checkedRows.push(element.id);
            }
        });
    }

    handleAllCheckboxesClick(event) {
        let recordIdArray = this.resetRecordIdArray();
        this.template.querySelectorAll('c-checkbox').forEach((element) => {
            element.setCheckboxValue(event.detail);
        });
        let tempArr = recordIdArray.map((x) => ({ ...x, checked: event.detail }));
        tempArr.forEach((element) => {
            if (element.checked) {
                this.checkedRows.push(element.id);
            }
        });
    }

    resetRecordIdArray() {
        this.checkedRows = [];
        let recordArray = Object.entries(this.recordMap);
        let recordIdArray = [];
        recordArray.forEach((element) => {
            recordIdArray.push({ id: element[0], checked: false });
        });
        return recordIdArray;
    }
}
