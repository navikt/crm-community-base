import { LightningElement, api } from 'lwc';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';

export default class Linktile extends LightningElement {
    @api linkLabel;
    @api linkHeader;
    @api linkAddress;
    @api id;
    @api chevron;
    @api maximumWidth;
    @api maximumHeight;
    @api borderOpacity; //"solid" or no argument for normal bordered tile and "solid transparent" for no border tile
    @api flexDirection;
    @api backgroundColor;
    @api justifyContent;
    @api desktopStyle;
    @api mobileStyle;
    @api imageUrl;
    @api imageMaxWidth;
    @api imageMaxHeight;
    @api altImageText;
    @api imageStyle;

    setFlex() {
        let flex = setDefaultValue(this.flexDirection, 'row').toLowerCase();
        if (flex !== 'row' && flex !== 'column') {
            return 'row';
        }
        return flex;
    }

    setBorderOpacity() {
        let borderOpacityToSet = setDefaultValue(this.borderOpacity, 'solid').toLowerCase();
        if (borderOpacityToSet !== 'solid' && borderOpacityToSet !== 'solid transparent') {
            return 'solid';
        }
        return borderOpacityToSet;
    }

    maxWidth() {
        return this.flexDirection === 'column'
            ? setDefaultValue(this.maximumWidth, 'fit-content')
            : setDefaultValue(this.maximumWidth, 'none');
    }

    maxHeight() {
        return setDefaultValue(this.maximumHeight, 'fit-content');
    }

    jContent() {
        return setDefaultValue(this.justifyContent, 'space-between');
    }

    setBackgroundColor() {
        return setDefaultValue(this.backgroundColor, '');
    }

    imgMaxWidth() {
        return setDefaultValue(this.imageMaxWidth, '50%');
    }

    imgMaxHeight() {
        return setDefaultValue(this.imageMaxHeight, '100%');
    }

    get defaultId() {
        return setDefaultValue(this.id, 'linkid');
    }

    get altImgText() {
        return setDefaultValue(this.altImageText, 'image');
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
            return setDefaultValue(style, 'text-align: center;');
        }
        if (this.image && this.setFlex() === 'row') {
            return setDefaultValue(
                style,
                'padding: 1rem; display: grid; grid-auto-flow: column; gap: 2rem; align-items: center;'
            );
        }
        return setDefaultValue(style, '');
    }

    get defaultImageStyle() {
        return setDefaultValue(this.imageStyle, 'text-align: center');
    }
    chevronValue = false;
    setChevron() {
        if (this.chevron !== undefined) {
            this.chevronValue = convertStringToBoolean(this.chevron);
        } else {
            let rowOrColumn = this.setFlex() === 'row';
            this.chevronValue = rowOrColumn ? true : false;
        }
    }

    image = false;
    renderedCallback() {
        document.documentElement.style.setProperty('--maxWidth', this.maxWidth());
        document.documentElement.style.setProperty('--maxHeight', this.maxHeight());
        document.documentElement.style.setProperty('--borderOpacity', this.setBorderOpacity());
        document.documentElement.style.setProperty('--flex', this.setFlex());
        document.documentElement.style.setProperty('--justifyContent', this.jContent());
        this.image = this.imageUrl !== undefined;
        this.rowOrColumn = this.setFlex() === 'row'; // True if row, false if column
        this.setChevron();
        // Row
        if (this.rowOrColumn && this.image) {
            document.documentElement.style.setProperty('--marginBlockStart', '1rem');
            document.documentElement.style.setProperty('--marginBlockEnd', '1rem');
            document.documentElement.style.setProperty('--navdsPanelPadding', '1rem');
            document.documentElement.style.setProperty('--backgroundColor', this.setBackgroundColor());
            document.documentElement.style.setProperty('--imgHeight', this.imgMaxHeight());
            document.documentElement.style.setProperty('--imgWidth', this.imgMaxWidth());
        }
        // Column
        if (!this.rowOrColumn && this.image) {
            document.documentElement.style.setProperty('--textMargin', '1rem');
            document.documentElement.style.setProperty('--backgroundColor', this.setBackgroundColor());
            document.documentElement.style.setProperty('--imgHeight', this.imgMaxHeight());
            document.documentElement.style.setProperty('--imgWidth', this.imgMaxWidth());
            document.documentElement.style.setProperty('--imgMargin', '1em 0 0 0');
        }
    }
}
