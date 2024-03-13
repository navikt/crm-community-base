import { LightningElement, api } from 'lwc';

export default class DsTextField extends LightningElement {
    @api size = 'medium'; // "medium" | "small"
    @api disabled;
    @api readOnly;
    @api label;
    @api type = 'text'; //"email" | "number" | "password" | "tel" | "text" | "url" | "time";
    @api autoComplete = 'off';
    @api description;
    @api required = false;
    @api maxLength;
    @api minLength;

    error;

    get inputElement() {
        return this.template.querySelector('.navds-text-field__input');
    }

    @api
    getValue() {
        return this.inputElement?.value;
    }

    @api
    focus() {
        this.inputElement?.focus();
    }

    get classes() {
        let classy = 'navds-form-field';
        classy += ` navds-form-field--${this.size}`;

        if (this.hasError) {
            classy += ' navds-text-field--error navds-date__field--error';
        }
        if (this.disabled) {
            classy += ' navds-text-field--disabled navds-form-field--disabled';
        }
        if (this.readOnly) {
            classy += ' navds-form-field--readonly navds-text-field--readonly';
        }

        return classy;
    }

    get labelClasses() {
        return (
            `navds-form-field__label navds-label navds-label--${this.size}` + (this.hideLabel ? ' navds-sr-only' : '')
        );
    }

    get inputClasses() {
        return (
            'navds-text-field__input navds-body-short navds-body-short--' + (this.size !== null ? this.size : 'medium')
        );
    }

    checkForError() {
        this.error = this.required && this.getValue() === '';
    }
}
