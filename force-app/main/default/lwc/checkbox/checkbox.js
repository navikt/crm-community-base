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
    @api helptextContent = '';
    @api helptextHovertext;
    @api name = '';
    @api form = '';
    @api desktopStyle;
    @api mobileStyle;

    handleCheckboxClick() {
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

    defaultVal;
    renderedCallback() {
        if (this.defaultVal) {
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

    showErrorText = false;
    updateShowErrorTextValue() {
        this.showErrorText = !this.template.querySelector('input').checked && this.errorText !== undefined && this.errorText !== '' && !this.disabled;
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
