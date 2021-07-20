import { LightningElement, api } from 'lwc';

// https://navikt.github.io/Designsystemet/?path=/story/ds-react-button--all
export default class Button extends LightningElement {
    @api autofocus;
    @api disabled;
    @api type; // Button, Submit, Reset
    @api value;
    @api buttonStyling; // Primary, Secondary, Action, Danger
    @api buttonLabel;

    get buttonClass() {
        let buttonStyle;

        if (
            this.buttonStyling !== 'primary' &&
            this.buttonStyling !== 'secondary' &&
            this.buttonStyling !== 'action' &&
            this.buttonStyling !== 'danger'
        ) {
            buttonStyle = 'primary'; // Set primary as default if invalid argument
        } else {
            buttonStyle = this.buttonStyling.toLowerCase();
        }
        return 'navds-button navds-button--' + buttonStyle + ' navds-body-short';
    }

    handleClick(event) {
        const eventToSend = new CustomEvent('buttonclick', { detail: event.target.value });
        this.dispatchEvent(eventToSend);
    }

    setDefault(value, valueToSet) {
        if (value === undefined) {
            value = valueToSet;
        }
        return value;
    }

    get setDefaultAutofocus() {
        return this.setDefault(this.autofocus, false);
    }

    get setDefaultDisabled() {
        return this.setDefault(this.disabled, false);
    }

    get setDefaultValue() {
        return this.setDefault(this.value, 'defaultValue');
    }

    get setDefaultType() {
        return this.setDefault(this.type, 'button');
    }
}
