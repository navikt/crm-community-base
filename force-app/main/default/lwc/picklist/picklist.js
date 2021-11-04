import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';
export default class Picklist extends LightningElement {
    @api masterLabel;
    @api id;
    @api choices = [];
    @api disabled;
    @api multiple;
    @api required;
    @api size;
    @api placeholder;
    @api helptext = false;
    @api helptextContent = '';
    @api desktopStyle;
    @api mobileStyle;

    @api choiceValue;
    handleChoiceMade(event) {
        for (let choice of this.choices) {
            if (choice.name === event.target.value) {
                this.choiceValue = choice;
            }
        }
        const eventToSend = new CustomEvent('picklistvaluechange', { detail: this.choiceValue });
        this.dispatchEvent(eventToSend);
    }

    get setDefaultId() {
        return setDefaultValue(this.id, 'picklist');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
    @api getElement() {
        return this.template.querySelector('select');
    }
}
