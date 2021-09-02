import { LightningElement, api } from 'lwc';

// https://navikt.github.io/Designsystemet/?path=/story/ds-react-button--all
export default class Button extends LightningElement {
    @api id;
    @api name;
    @api autofocus;
    @api disabled;
    @api type; // Button, Submit, Reset
    @api value;
    @api buttonStyling; // Primary, Secondary, Action, Danger
    @api buttonLabel;
    @api desktopStyle;
    @api mobileStyle;

    get buttonClass() {
        let buttonStyle;

        if (this.buttonStyling !== undefined) {
            buttonStyle = this.buttonStyling.toLowerCase();
        }
        if (
            this.buttonStyling !== 'primary' &&
            this.buttonStyling !== 'secondary' &&
            this.buttonStyling !== 'action' &&
            this.buttonStyling !== 'danger'
        ) {
            buttonStyle = 'primary'; // Set primary as default if invalid argument
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

    get setDefaultId() {
        return this.setDefault(this.id, 'button');
    }

    get setDefaultName() {
        return this.setDefault(this.name, 'button');
    }

    get setDefaultAutofocus() {
        return this.autofocus === 'true' ? true : false;
    }

    get setDefaultDisabled() {
        return this.disabled === 'true' ? true : false;
    }

    get setDefaultValue() {
        return this.setDefault(this.value, 'defaultValue');
    }

    get setDefaultType() {
        return this.setDefault(this.type, 'button');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return this.setDefault(style, '');
    }
}
