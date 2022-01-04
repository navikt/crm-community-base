import { LightningElement, api } from 'lwc';
import { setDefaultValue } from 'c/componentHelperClass';

export default class Breadcrumbs extends LightningElement {
    @api urlList = [];
    urlListToShow = [];
    @api desktopStyle;
    @api mobileStyle;

    connectedCallback() {
        let baseURLArray = window.location.pathname.split('/');
        baseURLArray.pop();
        let baseURL = baseURLArray.join('/');

        this.urlList.forEach(element => {
            this.urlListToShow.push({...element}); // Copy arr
        });
        this.urlListToShow.forEach(element => {
            element.href = baseURL + '/' + element.href;
        });
        this.removeElementsAfterIndex();
    }

    removeElementsAfterIndex() {
        let indexToSet = this.urlListToShow.length;
        this.urlListToShow.forEach((element, index) => {           
            if (element.href === window.location.pathname) {
                indexToSet = index+1;
            }
        });
        this.urlListToShow.length = indexToSet;
    }

    get setDefaultStyle() {
        let style = this.desktopStyle;
        if (window.screen.width < 576) {
            style = this.mobileStyle;
        }
        return setDefaultValue(style, '');
    }
}