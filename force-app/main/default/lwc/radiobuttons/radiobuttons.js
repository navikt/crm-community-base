import { api, LightningElement } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class radiobuttons extends LightningElement {
    @api header;
    @api groupName;
    @api form;
    @api flexDirection;
    @api errorText;
    @api labelSize;
    @api errorSize;
    @api helptextContent = '';
    @api helptextHovertext;
    @api description; 
    @api desktopStyle;
    @api mobileStyle;
    @api setDefaultValue;
    _radiobuttons = [];
    @api
    get radiobuttons() {
        return this._radiobuttons;
    }
    get descriptionId() {
        return this.description ? `${this.setDefaultId}-description` : undefined;
    }
    set radiobuttons(value) {
        this._radiobuttons = Array.isArray(value) ? value.map(rb => ({
        ...rb,
        ariaDescription: this.buildScreenReaderText(rb)
        })) : [];
        this.checkedValues = [];
    }

    buildScreenReaderText(radio) {
        if (!radio) {
            return null;
        }

        return radio.description
            ? `${radio.label} ${radio.description}`
            : radio.label;
    }


    checkedValues = [];
    handleRadiobuttonsClick() {
        this.updateShowErrorTextValue();
        this.checkedValues = this._radiobuttons.map((obj) => ({ ...obj, checked: false }));
        for (let i = 0; i < this._radiobuttons.length; i++) {
            const input = this.template.querySelector('[data-id="' + this._radiobuttons[i].label + '"]');
            if (input) {
                this.checkedValues[i].checked = input.checked;
            }
        }
        const eventToSend = new CustomEvent('radiobuttonsclick', { detail: this.checkedValues });
        this.dispatchEvent(eventToSend);
    }

    @api getValue() {
        return this.checkedValues;
    }

    get isHelpText() {
        return this.helptextContent !== '' && this.helptextContent !== undefined ? true : false;
    }

    bottomErrorText = false;
    bottomErrorTextWhenRow = false;
    updateShowErrorTextValue() {
        let error = false;
        this.bottomErrorText = false;
        this.bottomErrorTextWhenRow = false;
        let checked = false;
        // Check for checked values and error
        this._radiobuttons.forEach((element, index) => {
            const input = this.template.querySelector('[data-id="' + element.label + '"]');
            checked = input ? input.checked : false;
            if (this.checkIfError(checked, element.required, element.disabled)) {
                error = true;
                this.template.querySelectorAll('label')[index].classList.add('navds-error__label');
                this.showError(index);
            } else {
                this.template.querySelectorAll('label')[index].classList.remove('navds-error__label');
            }
        });
        return error;
    }

    // Need to set value again on render to avoid user having to click twice on radiobutton
    renderedCallback() {
        if (this.checkedValues.length > 0) {
            for (let i = 0; i < this._radiobuttons.length; i++) {
                const input = this.template.querySelector('[data-id="' + this._radiobuttons[i].label + '"]');
                if (input) input.checked = this.checkedValues[i].checked;
            }
        } else {
            this._radiobuttons.forEach((rb) => {
                const input = this.template.querySelector('[data-id="' + rb.label + '"]');
                if (input) input.checked = !!rb.checked;
            });
            if (this.setDefaultValue != null && this.setDefaultValue !== '') {
                const defaultValue = this.setDefaultValue.toString().toLowerCase();
                const anyChecked = this._radiobuttons.some(rb => !!rb.checked);
                if (!anyChecked) {
                    this._radiobuttons.forEach((radioButton) => {
                        const radioValue = radioButton.value.toString().toLowerCase();
                        const radioInput = this.template.querySelector('[data-id="' + radioButton.label + '"]');
                        if (radioInput && radioValue === defaultValue) {
                            radioInput.checked = true;
                        }
                    });
                }
            }
        }
    }

    showError(i) {
        let inputComponent = this.template.querySelectorAll('input')[i];
        inputComponent.focus();
        if (this.setFlex() !== 'row') {
            this.bottomErrorText = true;
        }
        if (this.setFlex() === 'row') {
            this.bottomErrorTextWhenRow = true;
        }
    }

    @api
    validationHandler() {
        return this.updateShowErrorTextValue();
    }

    checkIfError(checked, required, disabled) {
        if (required === undefined || !required || disabled) {
            return false;
        }
        return this.errorText !== undefined && this.errorText !== '' && !checked;
    }

    setFlex() {
        let flex = setDefaultValue(this.flexDirection, 'column').toLowerCase();
        if (flex !== 'row' && flex !== 'column') {
            return 'column';
        }
        return flex;
    }

    get labelFontSize() {
        return setDefaultValue(this.labelSize, '1.125rem');
    }

    get errorFontSize() {
        return setDefaultValue(this.errorSize, '1.125rem');
    }

    get flex() {
        let flex = 'display: flex; flex-direction: ' + this.setFlex() + '; ';
        let align = this.setFlex() === 'column' ? ' align-items: flex-start; ' : 'align-items: center; ';
        let gap = this.setFlex() === 'column' ? "gap: ''" : 'gap: 24px;';
        return flex + align + gap;
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}
