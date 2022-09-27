import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';

export default class Linktile extends NavigationMixin(LightningElement) {
    @api linkLabel;
    @api linkHeader;
    @api linkAddress;
    @api navigationAddress;
    @api id = 'linkId';
    @api chevron;
    @api maximumWidth;
    @api maximumHeight;
    @api borderOpacity; //"solid" or no argument for normal bordered tile and "solid transparent" for no border tile
    @api flexDirection;
    @api backgroundColor;
    @api justifyContent;
    @api desktopStyle;
    @api mobileStyle;
    @api customTextStyle;
    @api imageUrl;
    @api imageMaxWidth;
    @api imageMaxHeight;
    @api altImageText = 'image';
    @api imageStyle;

    setFlex() {
        let flex = setDefaultValue(this.flexDirection, 'row').toLowerCase();
        if (flex !== 'row' && flex !== 'column') {
            return 'row; ';
        }
        return flex;
    }

    setBorderOpacity() {
        let borderOpacityToSet = setDefaultValue(this.borderOpacity, 'solid').toLowerCase();
        if (borderOpacityToSet !== 'solid' && borderOpacityToSet !== 'solid transparent') {
            return 'solid; ';
        }
        return borderOpacityToSet + '; ';
    }

    maxWidth() {
        return this.flexDirection === 'column'
            ? setDefaultValue(this.maximumWidth, 'fit-content; ')
            : setDefaultValue(this.maximumWidth, 'none; ');
    }

    maxHeight() {
        return setDefaultValue(this.maximumHeight, 'fit-content; ');
    }

    jContent() {
        return setDefaultValue(this.justifyContent, 'space-between; ');
    }

    imgMaxWidth() {
        return setDefaultValue(this.imageMaxWidth, '50%; ');
    }

    imgMaxHeight() {
        return setDefaultValue(this.imageMaxHeight, '100%; ');
    }

    get isNavigation() {
        return this.navigationAddress !== null && this.navigationAddress !== undefined;
    }

    get hasLinkLabel() {
        return this.linkLabel !== undefined;
    }

    get hasLinkHeader() {
        return this.linkHeader !== undefined;
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
        if (this.image && this.rowOrColumn === 'column') {
            return setDefaultValue(style, 'text-align: center; display: inline-block; ');
        }
        if (this.image && this.rowOrColumn === 'row') {
            return setDefaultValue(style, 'display: grid; grid-auto-flow: column; gap: 1rem; align-items: center; ');
        }
        return setDefaultValue(style, '');
    }

    get setChevron() {
        if (this.chevron !== undefined) {
            return convertStringToBoolean(this.chevron);
        }
        return this.rowOrColumn === 'row';
    }

    get setMiscStyles() {
        let toReturn;
        let width = 'max-width: ' + this.maxWidth() + ';';
        let height = 'max-height: ' + this.maxHeight() + '; ';
        let borderOpacity = 'border: 1px ' + this.setBorderOpacity() + '; ';
        let flex = 'flex-direction: ' + this.rowOrColumn + '; ';
        let justifyContent = 'justify-content: ' + this.jContent() + '; ';
        let borderColor = 'border-color: #A0A0A0; ';
        let padding = this.backgroundColor !== undefined ? 'padding: 0; ' : ''; // Assume no padding on img if background color
        toReturn = width + height + borderOpacity + flex + justifyContent + borderColor + padding;

        return toReturn;
    }

    get setRowMarginStyling() {
        if (this.rowOrColumn === 'row' && this.linkLabel !== undefined) {
            return 'margin-top: 0.5rem; ';
        }
        return '';
    }

    get setImageStyle() {
        let toReturn = setDefaultValue(this.imageStyle, 'text-align: center; ');
        if (this.backgroundColor !== undefined && this.image) {
            toReturn = toReturn + 'background-color: ' + this.backgroundColor + '; ';
        }
        return toReturn;
    }

    get setImgStyle() {
        let toReturn;
        if (this.image) {
            let maxHeight = 'max-height: ' + this.imgMaxHeight() + '; ';
            let maxWidth = 'max-width: ' + this.imgMaxWidth() + '; ';
            toReturn = maxHeight + maxWidth;
        }
        if (this.rowOrColumn === 'column' && this.image) {
            toReturn = toReturn + 'margin: 1em 0 0 0;';
        }
        return toReturn;
    }

    get image() {
        return this.imageUrl !== undefined;
    }

    get customTextClassStyle() {
        return setDefaultValue(this.customTextStyle, '');
    }

    rowOrColumn = 'row';
    connectedCallback() {
        this.rowOrColumn = this.setFlex();
        if (this.isNavigation) {
            this.linkAddress = "";
        }
    }

    navigateToPage() {
        if (!this.isNavigation) {
            return;
        }
        this[NavigationMixin.Navigate]({
          type: 'comm__namedPage',
          attributes: {
            name: this.navigationAddress
          }
        });
    }
}