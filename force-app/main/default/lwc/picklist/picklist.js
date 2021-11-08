import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';
export default class Picklist extends LightningElement {
    @api masterLabel;
    @api id;
    @api form;
    @api name = 'picklist';
    @api choices = [];
    @api disabled;
    @api multiple;
    @api required;
    @api size;
    @api errorText;
    @api placeholderText;
    @api helptext = false;
    @api helptextContent = '';
    @api desktopStyle;
    @api mobileStyle;

    choiceValue = { name: 'Placeholder', label: this.placeholderText, selected: true };
    handleChoiceMade(event) {
        for (let choice of this.choicesArray) {
            if (choice.name === event.target.value) {
                this.choiceValue = choice;
            }
        }
        const eventToSend = new CustomEvent('picklistvaluechange', { detail: this.choiceValue });
        this.dispatchEvent(eventToSend);
    }

    get choicesArray() {
        if (this.placeholderText !== undefined) {
            return [{ name: 'Placeholder', label: this.placeholderText, selected: true }, ...this.choices];
        }
        return this.choices;
    }

    get setDefaultId() {
        return setDefaultValue(this.id, 'picklist');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }

    @api getValue() {
        return this.choiceValue;
    }

    @api getElement() {
        return this.template.querySelector('select');
    }

    @api
    validationHandler() {
        return this.updateShowErrorTextValue();
    }

    showErrorText = false;
    updateShowErrorTextValue() {
        this.showErrorText =
            this.choiceValue.label === this.placeholderText &&
            this.errorText !== undefined &&
            this.errorText !== '' &&
            !this.disabled;
        if (this.showErrorText) {
            this.template.querySelector('.skjemaelement').classList.add('navds-select--error');
        } else {
            this.template.querySelector('.skjemaelement').classList.remove('navds-select--error');
        }
        return this.showErrorText;
    }
}
