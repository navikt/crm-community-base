import { LightningElement, api } from 'lwc';

export default class Textlink extends LightningElement {
    @api label;
    @api address;
    @api target;
    @api id;
    @api name;
    @api fontSize;
    @api iconAfter;
    @api iconBefore;
    @api svgWidth;
    @api svgHeight;
    @api svgViewbox;
    @api svgFill;
    @api pathShape;
    @api pathFillRule;
    @api pathClipRule;
    @api pathFill;
    @api desktopStyle;
    @api mobileStyle;

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }

    get linkId() {
        return this.setDefaultValue(this.id, 'link');
    }

    get linkName() {
        return this.setDefaultValue(this.name, 'name');
    }

    get width() {
        return this.setDefaultValue(this.svgWidth, '1em');
    }
    get height() {
        return this.setDefaultValue(this.svgHeight, '1em');
    }
    get viewbox() {
        return this.setDefaultValue(this.svgViewbox, '0 0 24 24');
    }
    get sFill() {
        return this.setDefaultValue(this.svgFill, 'none');
    }
    get shape() {
        return this.setDefaultValue(this.pathShape, 'M11 13v8h2v-8h8v-2h-8V3h-2v8H3v2h8z');
    }
    get fillRule() {
        return this.setDefaultValue(this.pathFillRule, 'evenodd');
    }
    get clipRule() {
        return this.setDefaultValue(this.pathClipRule, 'evenodd');
    }
    get pFill() {
        return this.setDefaultValue(this.pathFill, 'currentColor');
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if(window.screen.width < 576){
            style = this.mobileStyle;
        }
        return this.setDefault(style, '');
    }

    renderedCallback() {
        let fontSizeToSet = this.fontSize === undefined ? '1.125rem' : this.fontSize;
        document.documentElement.style.setProperty('--fontSize', fontSizeToSet);
    }
}
