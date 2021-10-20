import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Input extends LightningElement {
    @api type = 'text';
    @api name = '';
    @api alt = ''; // Alternate text for image
    @api label = '';
    @api width;
    @api height;
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

    // Call this when value is needed
    @api sendValue() {
        let inputValue = this.template.querySelector('input').value;
        return inputValue;
    }

    // Sends value on change
    sendValueOnChange() {
        let inputValue = this.template.querySelector('input').value;
        const selectedEvent = new CustomEvent('getvalueonchange', {
            detail: inputValue
        });
        this.dispatchEvent(selectedEvent);
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

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }

    defaultWidth() {
        return setDefaultValue(this.width, '100%');
    }

    defaultHeight() {
        return setDefaultValue(this.height, '48px');
    }

    renderedCallback() {
        document.documentElement.style.setProperty('--width', this.defaultWidth());
        document.documentElement.style.setProperty('--height', this.defaultHeight());
    }
}
