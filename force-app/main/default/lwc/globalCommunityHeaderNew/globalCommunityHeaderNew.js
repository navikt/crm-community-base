import { LightningElement, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import ID from '@salesforce/user/Id';
import CURRENT_USER from '@salesforce/schema/User.Name';

const fields = [CURRENT_USER];

var prevScrolled = 0;
const headerHeight = 91;
const headerStartPosition = 44;
var headerPosition = headerStartPosition;

window.addEventListener('scroll', () => {
    var scrolled = window.scrollY;
    console.log(scrolled);
    const difference = scrolled - prevScrolled;
    if(difference >= 0){
        if(headerPosition >= -headerHeight){ 
            headerPosition = headerPosition - difference;
        }
        else{
            headerPosition = -headerHeight
        }
    }
    else{
        if(headerPosition < 0){
            headerPosition = headerPosition - difference;
        }
        else if(scrolled < headerStartPosition){
            headerPosition = headerStartPosition - scrolled;
        }
        else{
            headerPosition = 0;
        }

    }
    
    document.documentElement.style.setProperty('--headerPosition', headerPosition.toString() + "px");
    var myVar = getComputedStyle(document.documentElement).getPropertyValue('--headerPosition');
    
    prevScrolled = scrolled;

});

export default class GlobalCommunityHeaderNew extends LightningElement {


    userId = ID;
	@wire(getRecord, { recordId: '$userId', fields })
    user;
	get currentUser() {
		return getFieldValue(this.user.data, CURRENT_USER);
    }
    

    handleOnScroll(){
    }


    @track searchPressed = false;
    handleOnClickSearch(event){
        this.searchPressed = !this.searchPressed;
    }
    @track varslerPressed = false;
    onHandleClickVarsler(){
        this.varslerPressed = !this.varslerPressed;
    }
    @track minSidePressed = false;
    handleOnClickMinSide(){
        this.minSidePressed = !this.minSidePressed;
    }


    @track menuPressed=false;
    handleOnClickMenu(event){
        this.menuPressed=!this.menuPressed;
        this.sendMenuSelectedEvent();
    }

    @track isPrivatPerson=true;
    @track isArbeidsgiver=false;
    @track isSamarbeidspartner=false;
    handleOnClickPrivatPerson(event){
        this.isPrivatPerson=true;
        this.isArbeidsgiver=false;
        this.isSamarbeidspartner=false;
        this.sendClientTypeSelectedEvent();  
    }
    handleOnClickArbeidsgiver(event){
        this.isPrivatPerson=false;
        this.isArbeidsgiver=true;
        this.isSamarbeidspartner=false;
        this.sendClientTypeSelectedEvent();
    }
    handleOnClickSamarbeidspartner(event){
        this.isPrivatPerson=false;
        this.isArbeidsgiver=false;
        this.isSamarbeidspartner=true;
        this.sendClientTypeSelectedEvent();
    }

    @wire(CurrentPageReference) pageRef;
    sendClientTypeSelectedEvent(){
        var data = {
            isPrivatPerson : this.isPrivatPerson,
            isArbeidsgiver : this.isArbeidsgiver,
            isSamarbeidspartner : this.isSamarbeidspartner,
        }
        fireEvent(this.pageRef, 'clienttypeselected', data);
    }
    sendMenuSelectedEvent(){
        fireEvent(this.pageRef, 'menuSelectedEvent', this.menuPressed);
    }
   

    
}
