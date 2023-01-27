import { LightningElement,api } from 'lwc';
import ICON_LOGO from '@salesforce/resourceUrl/icons';

export default class AlertBanner extends LightningElement {
    @api type;
    @api message='Sett inn tekst';
    @api size;

    warningIcon = ICON_LOGO + '/warningicon.svg';
    informationIcon = ICON_LOGO + '/informationicon.svg';
    errorIcon = ICON_LOGO +'/erroricon.svg'

    get iconName() {
        switch (this.type) {
            case 'Error':
                return this.errorIcon;
            case 'Warning':
                return this.warningIcon;
            default:
                return this.informationIcon;
        }
    }

    get classTextName(){
        switch(this.size){
            case 'L':
                return 'textLarge';
            case 'S':
                return 'textSmall';
            default :
                return 'textMedium';

        }
    }

    get widthClass(){
        switch(this.size){
            case 'L':
                return 'widthLarge';
            case 'S':
                return 'widthSmall';
            default :
                return 'widthMedium';

        } 
    }

    get setColorClass() {
            switch (this.type) {
                case 'Error':
                    return 'colorError';
                case 'Warning':
                    return 'colorWarning'; 
                default:
                    return 'colorInformation';
            }        
    }

}