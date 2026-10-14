import { LightningElement, api } from 'lwc';

let idCounter = 0;

export default class CommunityCombobox extends LightningElement {
    @api label = '';
    @api placeholder = '- Velg et alternativ -';
    @api options = [];
    @api required = false;
    @api invalid = false;
    @api error = '';
    @api errorMessage = '';

    _value = '';
    isOpen = false;
    inputFocused = false;
    searchText = '';
    highlightedIndex = -1;
    scrollPending = false;
    baseId = `comboboxfield-${idCounter++}`;

    @api
    get value() {
        return this._value;
    }

    set value(value) {
        this._value = value ?? '';
        this.searchText = '';
        this.highlightedIndex = -1;
    }

    get inputId() {
        return this.baseId;
    }

    get listId() {
        return `${this.baseId}-filtered-options`;
    }

    get errorId() {
        return `${this.baseId}-error`;
    }

    get displayError() {
        return this.error || this.errorMessage;
    }

    get hasErrorMessage() {
        return Boolean(this.displayError);
    }

    get hasError() {
        return this.invalid || this.hasErrorMessage;
    }

    get describedBy() {
        return this.hasErrorMessage ? this.errorId : null;
    }

    get fieldClass() {
        return `aksel-form-field aksel-form-field--medium${this.hasError ? ' aksel-combobox--error' : ''}`;
    }

    get virtuallyUnfocused() {
        return this.isOpen && Boolean(this.computedOptions[this.highlightedIndex]);
    }

    get wrapperInnerClass() {
        let className = 'aksel-combobox__wrapper-inner aksel-text-field__input';

        if (this.inputFocused) {
            className += ' combobox-input-focused';
        }

        if (this.virtuallyUnfocused) {
            className += ' aksel-combobox__wrapper-inner--virtually-unfocused';
        }

        return className;
    }

    get listHidden() {
        return !this.isOpen;
    }

    get listClass() {
        return `aksel-combobox__list aksel-combobox__list--with-hover${
            this.isOpen ? '' : ' aksel-combobox__list--closed'
        }`;
    }

    get normalizedOptions() {
        return (this.options || []).map((option, sourceIndex) => {
            const normalized = typeof option === 'string' ? { label: option, value: option } : option;

            return {
                ...normalized,
                domId: `${this.baseId}-option-${sourceIndex}`
            };
        });
    }

    get selectedOption() {
        return this.normalizedOptions.find((option) => option.value === this._value);
    }

    get selectedLabel() {
        return this.selectedOption?.label || '';
    }

    get showSelectedLabel() {
        return Boolean(this.selectedOption) && !this.searchText;
    }

    get inputPlaceholder() {
        return this.selectedOption ? '' : this.placeholder;
    }

    get computedOptions() {
        const query = this.searchText.trim().toLocaleLowerCase();
        const options = this.normalizedOptions.filter((option) =>
            String(option.label).toLocaleLowerCase().includes(query)
        );

        const orderedOptions = [
            ...options.filter((option) => option.value === this._value),
            ...options.filter((option) => option.value !== this._value)
        ];

        return orderedOptions.map((option, index) => {
            const isSelected = option.value === this._value;
            const isActive = this.isOpen && index === this.highlightedIndex;
            let className = 'aksel-combobox__list-item';

            if (isSelected) {
                className += ' aksel-combobox__list-item--selected';
            }

            if (isActive) {
                className += ' aksel-combobox__list-item--focus';
            }

            return {
                ...option,
                index,
                isSelected,
                selected: isSelected ? 'true' : 'false',
                className
            };
        });
    }

    get hasNoOptions() {
        return this.computedOptions.length === 0;
    }

    get chevronPath() {
        return this.isOpen
            ? 'M11.47 7.97a.75.75 0 0 1 1.06 0l5.5 5.5a.75.75 0 1 1-1.06 1.06L12 9.56l-4.97 4.97a.75.75 0 0 1-1.06-1.06z'
            : 'M5.97 9.47a.75.75 0 0 1 1.06 0L12 14.44l4.97-4.97a.75.75 0 1 1 1.06 1.06l-5.5 5.5a.75.75 0 0 1-1.06 0l-5.5-5.5a.75.75 0 0 1 0-1.06';
    }

    renderedCallback() {
        const input = this.template.querySelector('input');
        const activeOption = this.isOpen
            ? this.template.querySelector(`[data-index="${this.highlightedIndex}"]`)
            : null;

        if (activeOption) {
            input.setAttribute('aria-activedescendant', activeOption.id);
        } else {
            input.removeAttribute('aria-activedescendant');
        }

        if (this.scrollPending) {
            this.scrollPending = false;
            activeOption?.scrollIntoView({ block: 'nearest', inline: 'nearest' });
        }
    }

    handleInputFocus() {
        this.inputFocused = true;
    }

    handleInputClick() {
        this.openList();
        this.highlightedIndex = -1;
    }

    handleSelectedLabelClick() {
        this.focusInput();
        this.openList();
    }

    handleInput(event) {
        this.searchText = event.target.value;
        this.openList();
        this.highlightedIndex = -1;
    }

    handlePreserveFocus(event) {
        event.preventDefault();
    }

    handleOptionMouseEnter(event) {
        this.highlightedIndex = Number(event.currentTarget.dataset.index);
    }

    handleOptionClick(event) {
        this.selectOption(Number(event.currentTarget.dataset.index));
    }

    toggleList() {
        this.focusInput();

        if (this.isOpen) {
            this.closeList();
        } else {
            this.openList();
        }
    }

    openList() {
        this.isOpen = true;
    }

    closeList() {
        this.isOpen = false;
        this.highlightedIndex = -1;
        this.searchText = '';
    }

    focusInput() {
        this.template.querySelector('input')?.focus();
    }

    handleFocusOut(event) {
        if (!event.relatedTarget || !this.template.contains(event.relatedTarget)) {
            this.inputFocused = false;
            this.closeList();
        }
    }

    setActiveOption(index) {
        this.highlightedIndex = index;
        this.scrollPending = true;
    }

    handleInputKeydown(event) {
        const options = this.computedOptions;

        switch (event.key) {
            case 'ArrowDown':
                event.preventDefault();
                this.openList();

                if (options.length) {
                    this.setActiveOption(this.highlightedIndex < options.length - 1 ? this.highlightedIndex + 1 : 0);
                }
                break;

            case 'ArrowUp':
                event.preventDefault();
                this.openList();

                if (options.length) {
                    this.setActiveOption(this.highlightedIndex > 0 ? this.highlightedIndex - 1 : options.length - 1);
                }
                break;

            case 'Enter':
                event.preventDefault();

                if (!this.isOpen) {
                    this.openList();
                } else if (options[this.highlightedIndex]) {
                    this.selectOption(this.highlightedIndex);
                }
                break;

            case 'Escape':
                if (this.isOpen) {
                    event.preventDefault();
                    this.closeList();
                }
                break;

            case 'Tab':
                this.closeList();
                break;

            default:
                break;
        }
    }

    selectOption(index) {
        const option = this.computedOptions[index];

        if (!option) {
            return;
        }

        this._value = option.value;
        this.closeList();
        this.focusInput();

        this.dispatchEvent(
            new CustomEvent('selectionchange', {
                detail: { value: option.value }
            })
        );
    }
}
