import { LightningElement, track } from 'lwc';

export default class GlobalCommunityHeaderNew extends LightningElement {

    handleOnScroll(){
    }


    @track searchPressed = false;
    handleOnClickSearch(event){
        this.searchPressed = !this.searchPressed;
        console.log(this.searchPressed);
    }
    @track searchInput;
    @track newPage ="";
    handleSearching(event){
        this.searchInput = event.target.value;
        var formatedSearch = this.searchInput.split(" ").join("%20");
        this.newPage = 'https://www.nav.no/sok\?ord=' + formatedSearch;
        console.log(this.newPage);
        this.loadSearchResults();
    }
    loadSearchResults(){
        console.log("loadSearchResults");
    }
    handleSearch(){
        return this.newPage;
    
    }


    @track menuPressed=false;
    handleOnClickMenu(event){
        this.menuPressed=!this.menuPressed;
    }
    @track isPrivatPerson=true;
    @track isArbeidsgiver=false;
    @track isSamarbeidspartner=false;
    handleOnClickPrivatPerson(){
        this.isPrivatPerson=true;
        this.isArbeidsgiver=false;
        this.isSamarbeidspartner=false;
    }
    handleOnClickArbeidsgiver(){
        this.isPrivatPerson=false;
        this.isArbeidsgiver=true;
        this.isSamarbeidspartner=false;
    }
    handleOnClickSamarbeidspartner(){
        this.isPrivatPerson=false;
        this.isArbeidsgiver=false;
        this.isSamarbeidspartner=true;
    }

    
}
