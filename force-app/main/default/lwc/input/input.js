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
        this.showError = this.errorText !== undefined && this.errorText !== '' && !this.disabled && 
        (this.template.querySelector('input').value === undefined || 
        this.template.querySelector('input').value === '' || 
        this.template.querySelector('input').value === null);
        this.setErrorCss();
        return this.showError;
    }

    setErrorCss() {
        if (this.showError) {
            this.template.querySelector('.navds-form-field').classList.add('navds-text-field--error');
            this.template.querySelector('input').focus();
        } else {
            this.template.querySelector('.navds-form-field').classList.remove('navds-text-field--error');
        }
    }

    // Checks if number is mobile, ref: https://no.wikipedia.org/wiki/Nummerplan_(E.164)
    // Returns true if mobile
    @api
    validatePhone() {
        let num = this.template.querySelector('input').value.replace(' ', '');
        if (num.substring(0, 3) === '+47') {
            num = num.substring(3, num.length);
        }
        if (num.substring(0, 4) === '0047') {
            num = num.substring(4, num.length);
        }
        if (num.substring(0,2) === '47' && num.length === 10) {
            num = num.substring(2, num.length);
        }
        if (num.substring(0,3) === '047' && num.length === 11) {
            num = num.substring(3, num.length);
        }
        if (num.length === 8 && num.charAt(0) === '4' || num.charAt(0) === '9') {
            this.showError = false;
        } else {
            this.showError = true;
        }
        this.setErrorCss();
        return this.showError;
    }

    // Sends value on change
    sendValueOnChange() {
        let inputValue = this.template.querySelector('input').value;
        this.setValue = inputValue;
        const selectedEvent = new CustomEvent('getvalueonchange', {
            detail: inputValue
        });
        if (this.showError) {
            this.showError = this.updateShowErrorTextValue();
        }
        this.dispatchEvent(selectedEvent);
    }

    @api validateOrgNumber() {
        let regExp = RegExp('\\d{9}');
        this.showError = regExp.test(this.template.querySelector('input').value) ? false : true;
        this.setErrorCss();
        return this.showError;
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
