import { LightningElement, api } from 'lwc';

export default class NksReadMore extends LightningElement {
    @api title;
    @api content;

    isExpanded = false;

    toggleExpand() {
        this.isExpanded = !this.isExpanded;
    }

    get ariaHidden() {
        return this.isExpanded ? 'false' : 'true';
    }

    get dataState() {
        return this.isExpanded ? 'closed' : 'open';
    }
}
