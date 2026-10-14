import { LightningElement, api } from 'lwc';

export default class DsHelpText extends LightningElement {
    @api title = 'Mangler tittel';
    @api text = 'Mangler tekst';

    open = false;
    ariaExpanded = false;

    helpTextClick() {
        const hidden = this.template.querySelector('.aksel-popover--hidden');
        if (hidden === null) {
            this.helpTextBlur();
        } else {
            this.ariaExpanded = true;
        }
    }

    helpTextBlur() {
        this.ariaExpanded = false;
    }

    keyboardHandler(event) {
        if (event.key === 'Escape') {
            this.ariaExpanded = false;
        }
    }

    focusClose(event) {
        const div = this.template.querySelector('.tester1');
        if (event.relatedTarget === null || !div.contains(event.relatedTarget)) this.ariaExpanded = false;
    }

    get popoverClasses() {
        return (
            'aksel-popover aksel-help-text__popover overrideableClasses popoverTop popoverRight--mobile popoverPosition' +
            (this.ariaExpanded === true ? '' : ' aksel-popover--hidden')
        );
    }
}
