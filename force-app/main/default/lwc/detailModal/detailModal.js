import { LightningElement, api } from 'lwc';

export default class DetailModal extends LightningElement {
    @api header;
    @api contents = []; //subheader & content
    @api maxWidth;
    @api maxHeight;
    @api marginLeft;
    @api marginRight;
    @api desktopStyle;
    @api mobileStyle;
    @api contentAsPrimitive;

    closeModal() {
        this.template.querySelector('.ReactModal__Overlay').classList.add('hidden');
    }

    @api showModal() {
        this.template.querySelector('.ReactModal__Overlay').classList.remove('hidden');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return this.setDefaultValue(style, '');
    }

    get setContentAsPrimitive() {
        return this.setDefaultValue(this.contentAsPrimitive, false);
    }

    defaultMaxWidth() {
        return this.setDefaultValue(this.maxWidth, '100%');
    }

    defaultMaxHeight() {
        return this.setDefaultValue(this.maxHeight, '100%');
    }

    defaultMarginLeft() {
        return this.setDefaultValue(this.marginLeft, 0);
    }

    defaultMarginRight() {
        return this.setDefaultValue(this.marginRight, 0);
    }

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }

    renderedCallback() {
        document.documentElement.style.setProperty('--maxWidth', this.defaultMaxWidth());
        document.documentElement.style.setProperty('--maxHeight', this.defaultMaxHeight());
        document.documentElement.style.setProperty('--marginLeft', this.defaultMarginLeft());
        document.documentElement.style.setProperty('--marginRight', this.defaultMarginRight());
    }
}
