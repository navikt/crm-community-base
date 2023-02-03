import { LightningElement,api,track } from 'lwc';
import { setDefaultValue, convertStringToBoolean } from 'c/componentHelperClass';

export default class Readmore extends LightningElement {
    @api id = 1;
    @api label;
    @track ariaExpanded = false;
    @api backgroundColor;
    @api fontSize;
    @api hoverBackGroundColor;
    @api focusBackGroundColor;
    @api titleFontWeight;

    renderedCallback() { 

        this.setDefaultCssProperties();
        this.initCSSVariables();
    }

    initCSSVariables() {
        var css = this.template.host.style;
        css.setProperty('--main-bg-color', this.backgroundColor);
        css.setProperty('--main-font-size',this.fontSize +'rem');
        css.setProperty('--hover-bg-color',this.hoverBackGroundColor);
        css.setProperty('--focus-bg-color',this.focusBackGroundColor);
        css.setProperty('--title-font-weight',this.titleFontWeight);
    }

     setDefaultCssProperties() {
        if (this.backgroundColor === undefined) {
            this.backgroundColor = '#FFFFFF';
        }

        if(this.fontSize === undefined){
            this.fontSize = '1.125';
        }

        if(this.hoverBackGroundColor === undefined){
            this.hoverBackGroundColor = '#E6F0FF';
        }

        if(this.focusBackGroundColor === undefined){
            this.focusBackGroundColor = '#E6F0FF'
        }

        if(this.titleFontWeight === undefined){
            this.titleFontWeight = '400';
        }
    }

    toggleSection(event){
        this.ariaExpanded = !this.ariaExpanded;
        let buttonid = event.currentTarget.dataset.buttonid;
        let currentsection = this.template.querySelector('[data-id="'+buttonid + '"]');
        if(currentsection.className.search('slds-is-open')==-1){
            currentsection.className = 'slds-section slds-is-open';
        }else{
            currentsection.className = 'slds-section slds-is-close';
        }
    }
}