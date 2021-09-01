import { api, LightningElement } from 'lwc';

export default class Radiobuttons extends LightningElement {
    @api radiobuttons = [];
    @api header;
    @api groupName;
    @api flexDirection;
    @api errorText;
    @api labelSize;
    @api errorSize;
    @api desktopStyle;
    @api mobileStyle;

    handleRadiobuttonsClick() {
        let checkedValues = [];
        for (let i = 0; i < this.radiobuttons.length; i++) {
            checkedValues[i] = this.template.querySelector('[data-id="' + this.radiobuttons[i].label + '"]').checked;
        }
        this.updateShowErrorTextValue();
        const eventToSend = new CustomEvent('radiobuttonsclick', { detail: checkedValues });
        this.dispatchEvent(eventToSend);
    }

    bottomErrorText = false;
    bottomErrorTextWhenRow = false;
    error = false;
    updateShowErrorTextValue() {
        this.bottomErrorText = false;
        this.bottomErrorTextWhenRow = false;
        let checked = false;
        // Check for checked values and error
        for (let i = 0; i < this.radiobuttons.length; i++) {
            checked = this.template.querySelector('[data-id="' + this.radiobuttons[i].label + '"]').checked;
            this.checkIfError(checked, this.radiobuttons[i].required, this.radiobuttons[i].disabled);

            if (this.error) {
                this.template.querySelectorAll('label')[i].style.setProperty('--border-color', '#ba3a26');
                this.template.querySelectorAll('label')[i].style.setProperty('--box-shadow', '0 0 0 1px #ba3a26');
                this.showError(i);
            } else {
                this.template.querySelectorAll('label')[i].style.setProperty('--border-color', '#a0a0a0');
                this.template.querySelectorAll('label')[i].style.setProperty('--box-shadow', '0 0 0 0');
                this.template.querySelectorAll('input')[i].setCustomValidity('');
            }
            this.template.querySelectorAll('input')[i].reportValidity();
        }
    }

    showError(i) {
        let inputComponent = this.template.querySelectorAll('input')[i];
        //inputComponent.setCustomValidity(this.errorText);
        inputComponent.focus();
        if (this.setFlex() !== 'row') {
            this.bottomErrorText = true;
        }
        if (this.setFlex() === 'row') {
            this.bottomErrorTextWhenRow = true;
        }
    }

    // True if err
    checkIfError(checked, required, disabled) {
        this.error = !checked && required && !disabled;
    }

    renderedCallback() {
        document.documentElement.style.setProperty('--label-size', this.defaultLabelSize());
        document.documentElement.style.setProperty('--error-size', this.defaultErrorSize());
        document.documentElement.style.setProperty('--flex', this.setFlex());
        document.documentElement.style.setProperty('--gap', this.setFlex() === 'column' ? '' : '24px');
        document.documentElement.style.setProperty(
            '--alignItems',
            this.setFlex() === 'column' ? 'flex-start' : 'center'
        );
    }

    defaultLabelSize() {
        return this.setDefaultValue(this.labelSize, '1.125rem');
    }

    defaultErrorSize() {
        return this.setDefaultValue(this.errorSize, '1rem');
    }

    setFlex() {
        let flex = this.setDefaultValue(this.flexDirection, 'column').toLowerCase();
        if (flex !== 'row' && flex !== 'column') {
            return 'column';
        }
        return flex;
    }

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return this.setDefaultValue(style, '');
    }
}
