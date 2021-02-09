import { LightningElement, api, track } from 'lwc';
import logos from '@salesforce/resourceUrl/logos';

export default class EmployerCommunityMenuItems extends LightningElement {
    navlogo = logos + '/navLogoRed.svg';
    @api area;

    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    @track showLogin;

    connectedCallback() {
        this.isPrivatperson = this.area == 'Privatperson';
        this.isArbeidsgiver = this.area == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.area == 'Samarbeidspartner';

        this.showLogin = this.area == 'Privatperson';
    }
}
