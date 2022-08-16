import { LightningElement, api } from 'lwc';

export default class DsButton extends LightningElement {
    // all attributes are case sensitive
    @api variant; //primary, secondary, tertiary, danger
    @api size; // medium, small
    @api disabled = false;
    @api loading = false; // not implemented
    @api text;

    get buttonClass() {
        return (
            'navds-button ' + 'navds-button--' + this.variant + (this.size === 'small' ? ' navds-button--small' : '')
        );
    }
    get textClass() {
        return 'navds-button__inner navds-body-short' + (this.size === 'small' ? ' navds-body-short-small' : '');
    }

    handleClick(event) {
        const eventToSend = new CustomEvent('buttonclick', { detail: event.target.value });
        this.dispatchEvent(eventToSend);
    }
}
