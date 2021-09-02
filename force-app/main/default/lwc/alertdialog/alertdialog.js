import { LightningElement, api } from 'lwc';
export default class Alertdialog extends LightningElement {
    @api header;
    @api content;
    @api maxWidth;
    @api maxHeight;
    @api marginLeft;
    @api marginRight;
    @api desktopStyle;
    @api mobileStyle;
    @api confirmButtonLabel;
    @api cancelButtonlabel;
    @api centerButtons;
    @api buttonPadding;
    @api noCancelButton;

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }

    handleButtonClick(event) {
        const eventToSend = new CustomEvent('buttonclick', { detail: event.target.value });
        this.closeModal();
        this.dispatchEvent(eventToSend);
    }

    closeModal() {
        this.template.querySelector('.ReactModal__Overlay').classList.add('hidden');
    }

    @api showModal() {
        this.template.querySelector('.ReactModal__Overlay').classList.remove('hidden');
    }

    get defaultConfirmButtonLabel() {
        return this.setDefaultValue(this.confirmButtonLabel, 'OK');
    }

    get defaultCancelButtonLabel() {
        return this.setDefaultValue(this.cancelButtonlabel, 'Avbryt');
    }

    get defaultNoCancelButton() {
        return this.setDefaultValue(this.noCancelButton, false);
    }

    setButtonPadding() {
        return this.setDefaultValue(this.buttonPadding, '10px');
    }

    setCenterButtons() {
        if (this.centerButtons === 'true') {
            return 'auto';
        }
        return 0;
    }

    defaultMaxWidth() {
        return this.setDefaultValue(this.maxWidth, '30%');
    }

    defaultMaxHeight() {
        return this.setDefaultValue(this.maxHeight, '30%');
    }

    defaultMarginLeft() {
        return this.setDefaultValue(this.marginLeft, 'auto');
    }

    defaultMarginRight() {
        return this.setDefaultValue(this.marginRight, 'auto');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return this.setDefaultValue(style, '');
    }

    renderedCallback() {
        document.documentElement.style.setProperty('--maxWidth', this.defaultMaxWidth());
        document.documentElement.style.setProperty('--maxHeight', this.defaultMaxHeight());
        document.documentElement.style.setProperty('--marginLeft', this.defaultMarginLeft());
        document.documentElement.style.setProperty('--marginRight', this.defaultMarginRight());
        document.documentElement.style.setProperty('--centerButtons', this.setCenterButtons());
        document.documentElement.style.setProperty('--buttonPadding', this.setButtonPadding());
    }
}
