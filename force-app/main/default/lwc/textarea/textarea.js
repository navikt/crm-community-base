import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Textarea extends LightningElement {
    @api name = 'textarea';
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
    @api placeholder = '';
    @api maxLength;
    @api id = "textareaid";
    @api rows;
    @api cols;
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

    get miscStyle() {
        let toReturn;
        if (this.cols === undefined) {
            toReturn = "width: 100%; ";
        }
        if (this.rows === undefined) {
            toReturn += "height: 114px; "
        }
        toReturn += "overflow: hidden;";
        return toReturn;
    }

    get setDefaultId() {
        return setDefaultValue(this.id, 'textarea');
    }

    get labelFontSize() {
        return 'font-size: ' + setDefaultValue(this.labelSize, '1.125rem') + ';';
    }

    get errorFontSize() {
        return 'font-size: ' + setDefaultValue(this.errorSize, '1.125rem') + ';' + ' margin-top: 8px;';
    }

    get isHelpText() {
        return this.helptextContent !== '' && this.helptextContent !== undefined ? true : false;
    }

    // Call this when value is needed
    @api getValue() {
        return this.template.querySelector('textarea').value;
    }

    showError = false;
    updateShowErrorTextValue() {
        this.showError =
            this.errorText !== undefined &&
            this.errorText !== '' &&
            !this.disabled &&
            (this.template.querySelector('textarea').value === undefined ||
                this.template.querySelector('textarea').value === '' ||
                this.template.querySelector('textarea').value === null);
        if (this.showError) {
            this.template.querySelector('.navds-form-field').classList.add('navds-textarea--error');
            this.template.querySelector('textarea').focus();
        } else {
            this.template.querySelector('.navds-form-field').classList.remove('navds-textarea--error');
        }
        return this.showError;
    }

    // Sends value on change
    sendValueOnChange() {
        let textareaValue = this.template.querySelector('textarea').value;
        const selectedEvent = new CustomEvent('getvalueontextareachange', {
            detail: textareaValue
        });
        if (this.showError) {
            this.setValue = this.template.querySelector('textarea').value;
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