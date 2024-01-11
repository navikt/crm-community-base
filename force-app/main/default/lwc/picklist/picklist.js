import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';
export default class Picklist extends LightningElement {
    @api masterLabel;
    @api id = 'picklistId';
    @api form;
    @api name = 'picklist';
    @api choices = [];
    @api disabled;
    @api multiple;
    @api size;
    @api errorText = '';
    @api helptextContent = '';
    @api helptextHovertext;
    @api desktopStyle;
    @api mobileStyle;
    @api setDefaultValue;
    choiceValue;

    connectedCallback() {
        for (let choice of this.choices) {
            if (choice.selected) {
                this.choiceValue = choice;
            }
        }
        if (this.setDefaultValue != '' || this.setDefaultValue != undefined) {
            const selectedChoice = this.choices.find((choice) => choice.name === this.setDefaultValue);
            if (selectedChoice) {
                this.choices = this.choices.map((choice) => ({
                    ...choice,
                    selected: choice.name === selectedChoice.name
                }));
                this.choiceValue = selectedChoice;
            }
        }
    }

    handleChoiceMade(event) {
        let eventToSend;
        let selectedValuesOnly = [];
        this.selectedValues = this.choices.map((obj) => ({ ...obj, selected: false }));
        if (this.multiple) {
            for (let i = 0; i < this.selectedValues.length; i++) {
                if (this.template.querySelector('[data-id="' + this.selectedValues[i].name + '"]').selected) {
                    this.selectedValues[i].selected = true;
                    selectedValuesOnly.push(this.selectedValues[i]);
                }
            }
            if (selectedValuesOnly.length > 0) {
                this.choiceValue = selectedValuesOnly[0]; // To prevent err from showing
            }
            eventToSend = new CustomEvent('picklistvaluechange', { detail: selectedValuesOnly });
        } else {
            for (let choice of this.choices) {
                if (choice.name === event.target.value) {
                    this.choiceValue = choice;
                }
            }
            eventToSend = new CustomEvent('picklistvaluechange', { detail: this.choiceValue });
        }
        if (this.showErrorText) {
            this.updateShowErrorTextValue();
        }
        this.dispatchEvent(eventToSend);
    }

    @api getValue() {
        return this.choiceValue;
    }

    get isHelpText() {
        return this.helptextContent !== '' && this.helptextContent !== undefined ? true : false;
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
            this.choiceValue.name === 'Placeholder' &&
            this.errorText !== undefined &&
            this.errorText !== '' &&
            !this.disabled;
        if (this.showErrorText) {
            this.template.querySelector('.skjemaelement').classList.add('navds-select--error');
            this.template.querySelector('select').focus();
        } else {
            this.template.querySelector('.skjemaelement').classList.remove('navds-select--error');
        }
        return this.showErrorText;
    }
}
