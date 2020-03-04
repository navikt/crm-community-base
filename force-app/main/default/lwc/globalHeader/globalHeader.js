import { LightningElement } from 'lwc';
import IDPORTEN_IKON from '@salesforce/resourceUrl/idporten_ikon';
import LOGO from '@salesforce/resourceUrl/logo';
import SEARCH_BUTTON from '@salesforce/resourceUrl/sok_liten_morkeblaa';

export default class GlobalHeader extends LightningElement {

    logo=LOGO;
    idportenIkon=IDPORTEN_IKON;
    searchButton=SEARCH_BUTTON;
}