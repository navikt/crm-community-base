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
    @api desktopStyle;
    @api mobileStyle;

    checked;
    handleCheckboxClick() {
        this.checked = this.template.querySelector('input').checked;
        this.updateShowErrorTextValue();
        const eventToSend = new CustomEvent('checkboxclick', { detail: this.checked });
        this.dispatchEvent(eventToSend);
    }

    @api
    validationHandler(errorMessage) {
        this.updateShowErrorTextValue();
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
    }

    connectedCallback() {
        this.defaultVal = convertStringToBoolean(this.defaultValue);
    }

    get labelFontSize() {
        return 'font-size: ' + setDefaultValue(this.labelSize + ';', '1.125rem;');
    }

    get errorFontSize() {
        return 'font-size: ' + setDefaultValue(this.errorSize + ';', '1.125rem;');
    }

    get setId() {
        return setDefaultValue(this.id, 'checkbox1');
    }

    updateShowErrorTextValue() {
        this.showErrorText = !this.checked && this.errorText !== undefined && this.errorText !== '' && !this.disabled;
        if (this.showErrorText) {
            this.template.querySelector('.navds-checkbox').classList.add('navds-checkbox--error');
        } else {
            this.template.querySelector('.navds-checkbox').classList.remove('navds-checkbox--error');
        }
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}
