export function setDefaultValue(value, valueToSet) {
    if (value === undefined) {
        return valueToSet;
    }
    return value;
}

export function convertStringToBoolean(stringValue) {
    if (stringValue !== undefined && typeof stringValue === 'string') {
        return stringValue.toLowerCase() === 'true';
    }
    return stringValue;
}
