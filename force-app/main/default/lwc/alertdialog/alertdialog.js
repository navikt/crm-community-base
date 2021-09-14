import { LightningElement, api } from 'lwc';
import { setDefaultValue, convertStringToBoolean} from 'c/componentHelperClass';
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
        this.template.querySelector('[data-id="alertdialog modal"]').focus();
    }

    get defaultConfirmButtonLabel() {
        return setDefaultValue(this.confirmButtonLabel, 'OK');
    }

    get defaultCancelButtonLabel() {
        return setDefaultValue(this.cancelButtonlabel, 'Avbryt');
    }

    get defaultNoCancelButton() {
        return setDefaultValue(this.noCancelButton, false);
    }

    setButtonPadding() {
        return setDefaultValue(this.buttonPadding, '10px');
    }

    setCenterButtons() {
        if (convertStringToBoolean(this.centerButtons)) {
            return 'auto';
        }
        return 0;
    }

    defaultMaxWidth() {
        return setDefaultValue(this.maxWidth, '30%');
    }

    defaultMaxHeight() {
        return setDefaultValue(this.maxHeight, '30%');
    }

    defaultMarginLeft() {
        return setDefaultValue(this.marginLeft, 'auto');
    }

    defaultMarginRight() {
        return setDefaultValue(this.marginRight, 'auto');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
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
