import { LightningElement, api } from 'lwc';

export default class Picklist extends LightningElement {
    @api masterLabel;
    @api id;
    @api choices = [];
    @api disabled;
    @api multiple;
    @api required;
    @api size;
    @api desktopStyle;
    @api mobileStyle;

    @api choiceValue;
    handleChoiceMade(event) {
        this.choiceValue = event.target.value;
        const eventToSend = new CustomEvent('picklistvaluechange', { detail: this.choiceValue });
        this.dispatchEvent(eventToSend);
    }

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }

    get setDefaultId() {
        return this.setDefaultValue(this.id, 'picklist');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return this.setDefaultValue(style, '');
    }
}
