import { LightningElement, api } from 'lwc';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';
export default class Alertdialog extends LightningElement {
    @api header;
    @api content;
    @api desktopStyle;
    @api mobileStyle;
    @api confirmButtonLabel;
    @api cancelButtonlabel;
    @api centerButtons;
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

    get setCenterButtons() {
        if (!convertStringToBoolean(this.centerButtons)) {
            return 'margin: 0';
        }
        return 'margin: auto';
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}
