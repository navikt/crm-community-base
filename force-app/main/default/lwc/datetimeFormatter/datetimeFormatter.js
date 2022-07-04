export function formatDatetime(initialDatetime) {
    let datetime = new Date(initialDatetime);
    return (
        datetime.toLocaleDateString() + ', ' + datetime.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    );
}

export function formatDate(initialDate) {
    let date = new Date(initialDate);
    return date.toLocaleDateString();
}

export function formatDatetimeinterval(initialStart, initialEnd) {
    let start = new Date(initialStart);
    let end = new Date(initialEnd);
    return (
        start.toLocaleDateString() +
        ', ' +
        start.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) +
        ' - ' +
        end.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    );
}

export function formatRecords(records, fields) {
    for (let record of records) {
        for (let field of fields) {
            if (field.type == 'datetime') {
                record[field.name] = formatDatetime(record[field.name]);
            } else if (field.type == 'date') {
                record[field.name] = formatDate(record[field.name]);
            } else if (field.type == 'datetimeinterval') {
                record[field.name] = formatDatetimeinterval(record[field.start], record[field.end]);
            }
        }
    }
    return records;
}
export function formatRecord(record, fields) {
    for (let field of fields) {
        if (field.type == 'datetime') {
            record[field.name] = formatDatetime(record[field.name]);
        } else if (field.type == 'date') {
            record[field.name] = formatDate(record[field.name]);
        } else if (field.type == 'datetimeinterval') {
            record[field.name] = formatDatetimeinterval(record[field.start], record[field.end]);
        }
    }
    return record;
}
