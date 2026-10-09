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
        return this.template.querySelector('.aksel-text-field__input');
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
        let classy = 'aksel-form-field';
        classy += ` aksel-form-field--${this.size}`;

        if (this.error) {
            classy += ' aksel-text-field--error aksel-date__field--error';
        }
        if (this.disabled) {
            classy += ' aksel-text-field--disabled aksel-form-field--disabled';
        }
        if (this.readOnly) {
            classy += ' aksel-form-field--readonly aksel-text-field--readonly';
        }

        return classy;
    }

    get labelClasses() {
        return (
            `aksel-form-field__label aksel-label aksel-label--${this.size}` + (this.hideLabel ? ' aksel-sr-only' : '')
        );
    }

    get inputClasses() {
        return (
            'aksel-text-field__input aksel-body-short aksel-body-short--' + (this.size !== null ? this.size : 'medium')
        );
    }

    checkForError() {
        this.error = this.required && this.getValue() === '';
    }
}
