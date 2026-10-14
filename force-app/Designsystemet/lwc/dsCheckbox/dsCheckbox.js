import { LightningElement, api } from 'lwc';

export default class CommunityCheckbox extends LightningElement {
    @api labelText;

    error = false;
    checked = false;

    get wrapperClass() {
        return 'aksel-checkbox aksel-checkbox--medium' + (this.error ? ' aksel-checkbox--error' : '');
    }

    checkError(event) {
        this.error = !event.target.checked;
    }

    toggleChecked() {
        this.checked = !this.checked;
        this.error = !this.checked;
        this.publishChange();
    }

    publishChange() {
        const checkedChangedEvent = new CustomEvent('checkedchanged', {
            detail: this.checked
        });
        this.dispatchEvent(checkedChangedEvent);
    }

    @api
    focus() {
        let checkbox = this.template.querySelector('.checkbox');
        checkbox.focus();
    }

    @api
    setChecked(value) {
        this.checked = value;
        this.error = !this.checked;
        this.publishChange();
    }
}
