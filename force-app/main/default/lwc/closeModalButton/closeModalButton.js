import { LightningElement } from 'lwc';

export default class CloseModalButton extends LightningElement {
    closeModal() {
        const eventToSend = new CustomEvent('handleclick', { detail: true });
        this.dispatchEvent(eventToSend);
    }
}
