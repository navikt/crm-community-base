import { api, LightningElement } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class radiobuttons extends LightningElement {
    @api radiobuttons = [];
    @api header;
    @api groupName;
    @api id;
    @api form;
    @api flexDirection;
    @api errorText;
    @api labelSize;
    @api errorSize;
    @api helptext = false;
    @api helptextContent = '';
    @api desktopStyle;
    @api mobileStyle;

    handleRadiobuttonsClick() {
        let checkedValues = this.radiobuttons.map((obj) => ({ ...obj, checked: false }));
        for (let i = 0; i < this.radiobuttons.length; i++) {
            checkedValues[i].checked = this.template.querySelector(
                '[data-id="' + this.radiobuttons[i].label + '"]'
            ).checked;
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
