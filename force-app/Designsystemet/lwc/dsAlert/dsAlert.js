import { LightningElement, api } from 'lwc';

export default class DsAlert extends LightningElement {
    @api alertType; // The type of alert ("info", "success", "warning", "danger")
    @api size = 'medium'; 
    @api alertText;
}
