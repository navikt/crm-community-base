import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Input extends LightningElement {
    @api type = 'text';
    @api name = 'input';
    @api alt = ''; // Alternate text for image
    @api label = '';
    @api value;
    @api form;
    @api helptextContent = '';
    @api errorText;
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
    setValue;

    isLabel = false;
    haslabel() {
        this.isLabel = this.label !== '' && this.label !== undefined;
    }

    connectedCallback() {
        this.setValue = this.value;
        this.haslabel();
    }

    get idValue() {
        return this.id !== '' && this.id !== undefined ? this.id : 'inputcomponent';
    }

    get labelFontSize() {
        return 'font-size: ' + setDefaultValue(this.labelSize, '1.125rem') + ';';
    }

    get errorFontSize() {
        return 'font-size: ' + setDefaultValue(this.errorSize, '1.125rem') + ';';
    }

    get isHelpText() {
        return this.helptextContent !== '' && this.helptextContent !== undefined ? true : false;
    }

    // Call this when value is needed
    @api getValue() {
        return this.template.querySelector('input').value;
    }

    showError = false;
    updateShowErrorTextValue() {
        this.showError =
            this.errorText !== undefined &&
            this.errorText !== '' &&
            !this.disabled &&
            (this.template.querySelector('input').value === undefined ||
                this.template.querySelector('input').value === '' ||
                this.template.querySelector('input').value === null);
        if (this.showError) {
            this.template.querySelector('.navds-form-field').classList.add('navds-text-field--error');
            this.template.querySelector('input').focus();
        } else {
            this.template.querySelector('.navds-form-field').classList.remove('navds-text-field--error');
        }
        return this.showError;
    }

    // Sends value on change
    sendValueOnChange() {
        let inputValue = this.template.querySelector('input').value;
        const selectedEvent = new CustomEvent('getvalueonchange', {
            detail: inputValue
        });
        if (this.showError) {
            this.setValue = this.template.querySelector('input').value;
            this.updateShowErrorTextValue();
        }
        this.dispatchEvent(selectedEvent);
    }

    @api
    validationHandler() {
        return this.updateShowErrorTextValue();
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}
