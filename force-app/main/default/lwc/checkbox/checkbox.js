import { api, LightningElement } from 'lwc';

export default class Checkbox extends LightningElement {
    @api label;
    @api errorText;
    @api defaultValue;
    @api disabled;
    @api labelSize;
    @api errorSize;

    checked;
    handleCheckboxClick() {
        this.checked = this.template.querySelector('input').checked;
        this.updateShowErrorTextValue();
        const eventToSend = new CustomEvent('checkboxclick', { detail: this.checked });
        this.dispatchEvent(eventToSend);
    }

    showErrorText = false;
    count = 0; // First render
    renderedCallback() {
        if (this.defaultValue && this.count < 1) {
            this.checked = true;
            this.template.querySelector('input').checked = true;
            this.updateShowErrorTextValue();
            this.count++;
        }

        if (this.disabled) {
            this.template.querySelector('input').disabled = true;
        }
        document.documentElement.style.setProperty('--label-size', this.defaultLabelSize());
        document.documentElement.style.setProperty('--error-size', this.defaultErrorSize());
    }

    defaultLabelSize() {
        return this.setDefaultValue(this.labelSize, '1.125rem');
    }

    defaultErrorSize() {
        return this.setDefaultValue(this.errorSize, '1.125rem');
    }

    connectedCallback() {
        this.updateShowErrorTextValue();
    }

    updateShowErrorTextValue() {
        this.showErrorText = !this.checked && this.errorText !== undefined && this.errorText !== '' && !this.disabled;
        if (this.showErrorText) {
            document.documentElement.style.setProperty('--box-shadow', '0 0 0 1px #ba3a26');
            document.documentElement.style.setProperty('--border-color', '#ba3a26');
        } else {
            document.documentElement.style.setProperty('--box-shadow', '0 0 0 0');
            document.documentElement.style.setProperty('--border-color', '#a0a0a0');
        }
    }

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }
}
