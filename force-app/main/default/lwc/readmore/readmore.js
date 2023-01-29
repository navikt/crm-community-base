import { LightningElement,api,track } from 'lwc';

export default class Readmore extends LightningElement {
    @api id = 1;
    @api label;
    @track ariaExpanded = false;
    @api maximumWidth;
    @api backgroundColor;
    @api fontSize;

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