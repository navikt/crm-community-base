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

    get mobileWrapStyle() {
        return window.screen.width < 576 ? 'white-space: normal;' : '';
    }
}