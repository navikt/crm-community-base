import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Input extends LightningElement {
    @api type = 'text';
    @api name = '';
    @api alt = ''; // Alternate text for image
    @api label = '';
    @api errorText = '';
    @api labelSize;
    @api errorSize;
    @api autofocus = false;
    @api disabled = false;
    @api required = false;
    @api readonly = false;
    @api maxLength = '255';
    @api minLength = '0';
    @api placeholder = '';
    @api id = 'inputcomponent';
    @api mobileStyle;
    @api desktopStyle;

    isLabel = false;
    haslabel() {
        this.isLabel = this.label !== '' && this.label !== undefined;
    }

    connectedCallback() {
        this.haslabel();
    }

    get idValue() {
        return this.id !== '' && this.id !== undefined ? this.id : 'inputcomponent';
    }

    get labelFontSize() {
        return setDefaultValue(this.labelSize, '1.125rem');
    }

    get errorFontSize() {
        return setDefaultValue(this.errorSize, '1.125rem');
    }

    // Call this when value is needed
    @api sendValue() {
        let inputValue = this.template.querySelector('input').value;
        return inputValue;
    }

    showError = false;
    updateError() {
        this.showError =
            this.template.querySelector('input').value === undefined ||
            this.template.querySelector('input').value === '';
        if (this.showError) {
            this.template.querySelector('.navds-form-field').classList.add('navds-text-field--error');
        } else {
            this.template.querySelector('.navds-form-field').classList.remove('navds-text-field--error');
        }
    }

    // Sends value on change
    sendValueOnChange() {
        this.updateError();
        let inputValue = this.template.querySelector('input').value;
        const selectedEvent = new CustomEvent('getvalueonchange', {
            detail: inputValue
        });
        this.dispatchEvent(selectedEvent);
    }

    @api
    validationHandler(errorMessage) {
        this.updateError();
        let inputEle = this.template.querySelector('input');
        inputEle.setCustomValidity(errorMessage);
        inputEle.reportValidity();
        if (errorMessage !== '') {
            inputEle.focus();
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
