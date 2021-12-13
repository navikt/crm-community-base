import { api, LightningElement } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class checkboxgroup extends LightningElement {
    @api checkboxes = [];
    @api header;
    @api groupName;
    @api form;
    @api flexDirection;
    @api errorText;
    @api labelSize;
    @api errorSize;
    @api helptextContent = '';
    @api helptextHovertext;
    @api desktopStyle;
    @api mobileStyle;

    checkboxValues = [];
    handleCheckboxClick() {
        this.updateShowErrorTextValue();
        this.checkboxValues = this.checkboxes.map((obj) => ({ ...obj, checked: false }));
        for (let i = 0; i < this.checkboxes.length; i++) {
            this.checkboxValues[i].checked = this.template.querySelector(
                '[data-id="' + this.checkboxValues[i].label + '"]'
            ).checked;
        }
        const eventToSend = new CustomEvent('checkboxgroupclick', { detail: this.checkboxValues });
        this.dispatchEvent(eventToSend);
    }

    @api getValue() {
        return this.checkboxValues;
    }

    get isHelpText() {
        return this.helptextContent !== '' && this.helptextContent !== undefined ? true : false;
    }

    @api sendErrorMessage(errorMessage) {
        this.bottomErrorText = errorMessage !== '';
        this.errorText = errorMessage;
        if (this.bottomErrorText) {
            this.template.querySelectorAll('label').forEach((element) => {
                element.classList.add('navds-error__label');
            });
        } else {
            this.template.querySelectorAll('label').forEach((element) => {
                element.classList.remove('navds-error__label');
            });
        }
        this.template.querySelector('fieldset').focus();
    }

    bottomErrorText = false;
    bottomErrorTextWhenRow = false;
    updateShowErrorTextValue() {
        let error = false;
        this.bottomErrorText = false;
        this.bottomErrorTextWhenRow = false;
        let checked = false;
        // Check for checked values and error
        this.checkboxes.forEach((element, index) => {
            checked = this.template.querySelector('[data-id="' + element.label + '"]').checked;
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
        return setDefaultValue(this.labelSize, 'font-size: 1.125rem;');
    }

    get errorFontSize() {
        return setDefaultValue(this.errorSize, 'font-size: 1.125rem;');
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
