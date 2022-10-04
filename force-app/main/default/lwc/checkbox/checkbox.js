import { api, LightningElement } from 'lwc';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';
export default class Checkbox extends LightningElement {
    @api label;
    @api errorText;
    @api id;
    @api defaultVal;
    @api disabled;
    @api labelSize;
    @api errorSize;
    @api helptextContent = '';
    @api helptextHovertext;
    @api ariaLabel;
    @api name = '';
    @api form = '';
    @api title;
    @api desktopStyle;
    @api mobileStyle;

    handleCheckboxClick(event) {
        event.stopPropagation();
        let checked = this.template.querySelector('input').checked;
        if (this.showErrorText) {
            this.updateShowErrorTextValue();
        }
        const eventToSend = new CustomEvent('checkboxclick', { detail: checked });
        this.dispatchEvent(eventToSend);
    }

    get isHelpText() {
        return this.helptextContent !== '' && this.helptextContent !== undefined ? true : false;
    }

    get ariaLabelValue() {
        return this.ariaLabel === undefined ? this.label : this.ariaLabel;
    }

    @api getValue() {
        return this.template.querySelector('input').checked;
    }

    @api
    validationHandler() {
        return this.updateShowErrorTextValue();
    }

    @api clearCheckboxValue() {
        this.template.querySelector('input').checked = false;
    }

    @api setCheckboxValue(value) {
        this.template.querySelector('input').checked = value;
    }

    @api focusCheckbox() {
        this.template.querySelector('[data-id="checkbox dataid"]').focus();
    }

    renderedCallback() {
        if (this.defaultVal) {
            this.template.querySelector('input').checked = true;
        }

        if (this.disabled) {
            this.template.querySelector('input').disabled = true;
        }
    }

    @api set defaultValue(val) {
        this.defaultVal = val;
        if (this.template.querySelector('input')) {
            this.setCheckboxValue(this.defaultVal);
        }
    }
    get defaultValue() {
        return this.defaultVal;
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

    showErrorText = false;
    updateShowErrorTextValue() {
        this.showErrorText =
            !this.template.querySelector('input').checked &&
            this.errorText !== undefined &&
            this.errorText !== '' &&
            !this.disabled;
        if (this.showErrorText) {
            this.template.querySelector('.navds-checkbox').classList.add('navds-checkbox--error');
            this.focusCheckbox();
        } else {
            this.template.querySelector('.navds-checkbox').classList.remove('navds-checkbox--error');
        }
        return this.showErrorText;
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}
