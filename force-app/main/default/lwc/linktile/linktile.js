import { LightningElement, api } from 'lwc';

export default class Linktile extends LightningElement {
    @api linkLabel;
    @api linkHeader;
    @api linkAddress;
    @api maximumWidth;
    @api maximumHeight;
    @api borderOpacity; //"solid" or no argument for normal bordered tile and "solid transparent" for no border tile
    @api flexDirection;
    @api justifyContent;
    @api desktopStyle;
    @api mobileStyle;
    @api imageUrl;
    @api imageWidth;
    @api imageHeight;
    @api altImageText;
    @api imageStyle;

    setDefaultValue(value, valueToSet) {
        if (value === undefined) {
            return valueToSet;
        }
        return value;
    }

    setFlex() {
        let flex = this.setDefaultValue(this.flexDirection, 'row').toLowerCase();
        if (flex !== 'row' && flex !== 'column') {
            return 'row';
        }
        return flex;
    }

    setBorderOpacity() {
        let borderOpacityToSet = this.setDefaultValue(this.borderOpacity, 'solid').toLowerCase();
        if (borderOpacityToSet !== 'solid' && borderOpacityToSet !== 'solid transparent') {
            return 'solid';
        }
        return borderOpacityToSet;
    }

    maxWidth() {
        return this.flexDirection === 'column'
            ? this.setDefaultValue(this.maximumWidth, 'fit-content')
            : this.setDefaultValue(this.maximumWidth, 'none');
    }

    maxHeight() {
        return this.setDefaultValue(this.maximumHeight, 'fit-content');
    }

    jContent() {
        return this.setDefaultValue(this.justifyContent, 'space-between');
    }

    get imgWidth() {
        return this.setDefaultValue(this.imageWidth, '50');
    }

    get imgHeight() {
        return this.setDefaultValue(this.imageHeight, '50');
    }

    get altImgText() {
        return this.setDefaultValue(this.altImageText, 'image');
    }

    // If linkHeader === undefined -> set linkLabel to linkHeader class
    get linkLabelClass() {
        if (this.linkHeader === undefined) {
            return 'navds-link-panel-title navds-title navds-title--m';
        }
        return 'navds-label';
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        if (this.image && this.setFlex() === 'column') {
            return this.setDefaultValue(style, 'padding: 1rem; gap: 2rem; align-items: center; text-align: center;');
        }
        if (this.image && this.setFlex() === 'row') {
            return this.setDefaultValue(
                style,
                'padding: 1rem; display: grid; grid-auto-flow: column; gap: 2rem; align-items: center;'
            );
        }
        return this.setDefaultValue(style, '');
    }

    get defaultImageStyle() {
        return this.setDefaultValue(this.imageStyle, 'text-align: center;');
    }

    // if flex-direction === column -> hide chevron
    image = false;
    chevron = true;
    renderedCallback() {
        document.documentElement.style.setProperty('--maxWidth', this.maxWidth());
        document.documentElement.style.setProperty('--maxHeight', this.maxHeight());
        document.documentElement.style.setProperty('--borderOpacity', this.setBorderOpacity());
        document.documentElement.style.setProperty('--flex', this.setFlex());
        document.documentElement.style.setProperty('--justifyContent', this.jContent());
        this.image = this.imageUrl !== undefined;
        this.chevron = this.setFlex() === 'row';
        if (this.chevron && this.image) {
            document.documentElement.style.setProperty('--marginBlockStart', '1em');
            document.documentElement.style.setProperty('--marginBlockEnd', '1em');
        }
    }
}
