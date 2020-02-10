import { LightningElement } from 'lwc';
import IDPORTEN_IKON from '@salesforce/resourceUrl/idporten_ikon';
import LOGO from '@salesforce/resourceUrl/logo';

export default class GlobalHeader extends LightningElement {

    logo=LOGO;
    idportenIkon=IDPORTEN_IKON;
}