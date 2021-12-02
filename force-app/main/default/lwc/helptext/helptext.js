import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Helptext extends LightningElement {
    @api hoverText;
    @api text;
    @api desktopStyle;
    @api mobileStyle;

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
    setHelptextPostition() {
        if (window.screen.width < 576) {
            let element = this.template.querySelector('.navds-help-text__button');
            let rect = element.getBoundingClientRect();
            let left = 3 - rect.left;
            let right = 3 + rect.right - window.screen.width;
            let arrowRight = window.screen.width - rect.right;
            let moveToRight = window.screen.width * 0.55 < rect.left;
            this.defaultStyle = 'left: ' + left + 'px;';
            this.arrowStyle = 'left: ' + rect.left + 'px;';
            if (moveToRight) {
                this.defaultStyle = 'left: auto; right: ' + right + 'px;';
                this.arrowStyle = 'left: auto; right: ' + arrowRight + 'px;';
            }
        }
    }
    defaultStyle = '';
    arrowStyle = '';
}
