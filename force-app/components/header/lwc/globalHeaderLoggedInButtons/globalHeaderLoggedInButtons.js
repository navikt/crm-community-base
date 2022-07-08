import { LightningElement, track, wire } from 'lwc';
// import { loadStyle } from 'lightning/platformResourceLoader';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ID from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';
import MIDDLE_NAME from '@salesforce/schema/User.MiddleName';
import LAST_NAME from '@salesforce/schema/User.LastName';

// import dekoratoren from '@salesforce/resourceUrl/dekoratoren';

const fields = [FIRST_NAME, MIDDLE_NAME, LAST_NAME];

export default class GlobalHeaderLoggedInButtons extends LightningElement {
    renderedCallback() {
        // loadStyle(this, dekoratoren);
    }

    @track varslerPressed = false;
    onHandleClickVarsler() {
        this.varslerPressed = !this.varslerPressed;
        this.minSidePressed = false;
    }

    @track minSidePressed = false;
    handleOnClickMinSide() {
        this.varslerPressed = false;
        this.minSidePressed = !this.minSidePressed;
    }

    userId = ID;
    @wire(getRecord, { recordId: '$userId', fields })
    user;
    get currentUser() {
        const firstName = getFieldValue(this.user.data, FIRST_NAME);
        const middleName = getFieldValue(this.user.data, MIDDLE_NAME);
        const lastName = getFieldValue(this.user.data, LAST_NAME);
        if (middleName) {
            return firstName + ' ' + middleName + ' ' + lastName;
        } else {
            return firstName + ' ' + lastName;
        }
    }
}
