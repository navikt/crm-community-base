import { LightningElement, api, track } from 'lwc';
import logos from '@salesforce/resourceUrl/logos';

export default class EmployerCommunityMenuItems extends LightningElement {
    navlogo = logos + '/navLogoRed.svg';
    @api NAVarea;
    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    connectedCallback() {
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';
    }
}