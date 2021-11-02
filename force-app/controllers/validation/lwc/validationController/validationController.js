export function validate(element, validationRules, ...args) {
    let errors = [];
    let hasErrors = 0;
    if (element != null && element != {}) {
        element.setCustomValidity('');
        element.reportValidity();
        for (let validationRule of validationRules) {
            let errorMessage = validationRule(element.value, args);
            if (errorMessage != '') {
                element.setCustomValidity(errorMessage);
                element.reportValidity();
                element.focus();
                errors.push(errorMessage);
                hasErrors = 1;
            }
        }
    }
    return hasErrors;
}

export function require(value) {
    return value == null || value == '' ? 'Fyll ut dette feltet.' : '';
}
