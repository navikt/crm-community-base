//returns mobile Sorting options based on columns-argument
export function getMobileSortingOptions(columns) {
    let mobileColumns = [];
    for (let column of columns) {
        if (column.sortable) {
            mobileColumns.push({
                label:
                    column.label +
                    (column.type == 'text' ? ' A - Å' : ' stigende'),
                value:
                    '{"fieldName": ' +
                    JSON.stringify(column.fieldName) +
                    ', "sortDirection": "asc"} '
            });
            mobileColumns.push({
                label:
                    column.label +
                    (column.type == 'text' ? ' Å - A' : ' synkende'),
                value:
                    '{"fieldName": ' +
                    JSON.stringify(column.fieldName) +
                    ', "sortDirection": "desc"} '
            });
        }
    }
    return mobileColumns;
}

//Sorting Controller
export function sortList(listOfObjects, property, sortDirection) {
    let cloneData = [...listOfObjects];
    cloneData.sort(sortBy(property, sortDirection === 'asc' ? 1 : -1));
    listOfObjects = cloneData;
    return listOfObjects;
}

function sortBy(property, reverse) {
    return function (object1, object2) {
        let value1 = getValue(object1, property).toString().toLowerCase();
        let value2 = getValue(object2, property).toString().toLowerCase();
        return reverse * ((value1 > value2) - (value2 > value1));
    };
}

function getValue(object, property) {
    return object[property] ? object[property] : '';
}
