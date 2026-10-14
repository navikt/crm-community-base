import { LightningElement, api } from 'lwc';

export default class CommunityAlert extends LightningElement {
    @api alertType;
    @api alertText;
}
