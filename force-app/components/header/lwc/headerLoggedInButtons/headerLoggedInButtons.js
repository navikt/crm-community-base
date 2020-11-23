import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
/*import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub'; 
import ID from '@salesforce/user/Id';
import FIRST_NAME from '@salesforce/schema/User.FirstName';
import MIDDLE_NAME from '@salesforce/schema/User.MiddleName';
import LAST_NAME from '@salesforce/schema/User.LastName';
/*import isProdFunction from '@salesforce/apex/GlobalCommunityHeaderFooterController.isProd'; */
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';


//const fields = [FIRST_NAME, MIDDLE_NAME, LAST_NAME];

export default class HeaderLoggedInButtons extends LightningElement {
    renderedCallback() {
        loadStyle(this, dekoratoren);
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

	/*@track isProd;
	@track error;
	@wire(isProdFunction)
	wiredIsProd({ error, data }) {
		this.isProd = data;
	}

	userId = ID;
	@wire(getRecord, { recordId: '$userId', fields })
	user;
	get currentUser() {
		const firstName = getFieldValue(this.user.data, FIRST_NAME);
		const middleName = getFieldValue(this.user.data, MIDDLE_NAME);
		const lastName = getFieldValue(this.user.data, LAST_NAME);
		if(middleName){
			return firstName + " " + middleName + " " + lastName;
		}
		else{
			return firstName + " " + lastName;
		}
	}

	@track searchPressed = false;
	handleOnClickSearch(event) {
		this.searchPressed = !this.searchPressed;
		this.varslerPressed = false;
		this.minSidePressed = false;
		this.menuPressed = false;
		this.isPrivatPerson = false;
		this.sendMenuSelectedEvent();
	}
	@track varslerPressed = false;
	onHandleClickVarsler() {
		this.varslerPressed = !this.varslerPressed;
		this.searchPressed = false;
		this.minSidePressed = false;
		this.menuPressed = false;
		this.isPrivatPerson = false;
		this.sendMenuSelectedEvent();
	}
	@track minSidePressed = false;
	handleOnClickMinSide() {
		this.varslerPressed = false;
		this.searchPressed = false;
		this.minSidePressed = !this.minSidePressed;
		this.menuPressed = false;
		this.isPrivatPerson = false;
		this.sendMenuSelectedEvent();
	}


	@track menuPressed = false;
	handleOnClickMenu(event) {
		//console.log("meny");
		this.varslerPressed = false;
		this.searchPressed = false;
		this.minSidePressed = false;
		this.menuPressed = !this.menuPressed;
		this.isPrivatPerson = !this.isPrivatPerson;
		this.sendMenuSelectedEvent();
	}
	@track isUnderMeny1 = false;
	@track isUnderMeny2 = false;
	@track isUnderMeny3 = false;
	@track isUnderMeny4 = false;
	@track isUnderMeny5 = false;
	@track isUnderMeny6 = false;
	@track isUnderMeny7 = false;
	@track isUnderMeny8 = false;
	onHandleBackToMenu() {
		this.isUnderMeny1 = false;
		this.isUnderMeny2 = false;
		this.isUnderMeny3 = false;
		this.isUnderMeny4 = false;
		this.isUnderMeny5 = false;
		this.isUnderMeny6 = false;
		this.isUnderMeny7 = false;
		this.isUnderMeny8 = false;
	}
	onHandleUnderMeny1() {
		this.isUnderMeny1 = true;
	}
	onHandleUnderMeny2() {
		this.isUnderMeny2 = true;
	}
	onHandleUnderMeny3() {
		this.isUnderMeny3 = true;
	}
	onHandleUnderMeny4() {
		this.isUnderMeny4 = true;
	}
	onHandleUnderMeny5() {
		this.isUnderMeny5 = true;
	}
	onHandleUnderMeny6() {
		this.isUnderMeny6 = true;
	}
	onHandleUnderMeny7() {
		this.isUnderMeny7 = true;
	}
	onHandleUnderMeny8() {
		this.isUnderMeny8 = true;
	}


	@track isPrivatPerson = false;
	@track isArbeidsgiver = false;
	@track isSamarbeidspartner = false;
	handleOnClickPrivatPerson(event) {
		this.isPrivatPerson = true;
		this.isArbeidsgiver = false;
		this.isSamarbeidspartner = false;
		this.sendClientTypeSelectedEvent();
	}
	handleOnClickArbeidsgiver(event) {
		this.isPrivatPerson = false;
		this.isArbeidsgiver = true;
		this.isSamarbeidspartner = false;
		this.sendClientTypeSelectedEvent();
	}
	handleOnClickSamarbeidspartner(event) {
		this.isPrivatPerson = false;
		this.isArbeidsgiver = false;
		this.isSamarbeidspartner = true;
		this.sendClientTypeSelectedEvent();
	}

	@wire(CurrentPageReference) pageRef;
	sendClientTypeSelectedEvent() {
		var data = {
			isPrivatPerson: this.isPrivatPerson,
			isArbeidsgiver: this.isArbeidsgiver,
			isSamarbeidspartner: this.isSamarbeidspartner,
		}
		fireEvent(this.pageRef, 'clienttypeselected', data);
	}
	sendMenuSelectedEvent() {
		fireEvent(this.pageRef, 'menuSelectedEvent', this.menuPressed);
	}
*/

}