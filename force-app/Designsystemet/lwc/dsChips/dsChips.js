import { LightningElement, api } from 'lwc';

export default class CommunityChips extends LightningElement {
    @api label = '';
    @api options = [];

    get computedOptions() {
        return (this.options || []).map((option) => ({
            ...option,
            selected: Boolean(option.selected),
            pressed: option.selected ? 'true' : 'false'
        }));
    }

    handleSelection(event) {
        const value = event.currentTarget.dataset.value;
        this.dispatchEvent(
            new CustomEvent('selectionchange', {
                detail: { value }
            })
        );
    }
}
