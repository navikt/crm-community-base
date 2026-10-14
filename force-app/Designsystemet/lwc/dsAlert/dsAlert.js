import { LightningElement, api } from 'lwc';

export default class DsAlert extends LightningElement {
    @api alertType;
    @api alertText;
}
