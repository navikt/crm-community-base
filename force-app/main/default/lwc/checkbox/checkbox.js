import { api, LightningElement } from 'lwc';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';
export default class Checkbox extends LightningElement {
    @api label;
    @api errorText;
    @api id;
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

    @api
    validationHandler(errorMessage) {
        let inputEle = this.template.querySelector('input');
        inputEle.setCustomValidity(errorMessage);
        inputEle.reportValidity();
        if (errorMessage !== '') {
            inputEle.focus();
        }
    }

    @api clearCheckboxValue() {
        this.template.querySelector('input').checked = false;
    }

    @api focusCheckbox() {
        this.template.querySelector('[data-id="checkbox dataid"]').focus();
    }

    showErrorText = false;
    defaultVal = false;
    renderedCallback() {
        if (this.defaultVal) {
            this.checked = true;
            this.template.querySelector('input').checked = true;
            this.defaultVal = false;
        }

        if (this.disabled) {
            this.template.querySelector('input').disabled = true;
        }
        document.documentElement.style.setProperty('--label-size', this.defaultLabelSize());
        document.documentElement.style.setProperty('--error-size', this.defaultErrorSize());
        this.updateShowErrorTextValue();
    }

    connectedCallback() {
        this.defaultVal = convertStringToBoolean(this.defaultValue);
    }

    defaultLabelSize() {
        return setDefaultValue(this.labelSize, '1.125rem');
    }

    defaultErrorSize() {
        return setDefaultValue(this.errorSize, '1.125rem');
    }

    get setId() {
        return setDefaultValue(this.id, 'checkbox1');
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
}
