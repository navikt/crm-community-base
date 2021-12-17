import { LightningElement, api } from 'lwc';

export default class Breadcrumbs extends LightningElement {
/*
urlList eks: 
breadcrumbs = [
        {
            label: 'Tolketjenesten',
            href: ''
        },
        {
            label: 'Ny bestilling',
            href: 'ny-bestilling'
        },
        {
            label: 'johnny',
            href: 'ny-bestilling/johnny'
        }
    ];
*/

    @api urlList = [];
    urlListToShow = [];

    connectedCallback() {
        let baseURLArray = window.location.pathname.split('/');
        baseURLArray.pop();
        let baseURL = baseURLArray.join('/');
        this.urlList.forEach(element => {
            this.urlListToShow.push({...element});
        });
        this.urlListToShow.forEach(element => {
            element.href = baseURL + '/' + element.href;
        });
        this.removeElementsAfterIndex();
    }

    // TODO: Hide all elements with index > current clicked index
    // TODO: Can remove this, already done in removelementsafterindex. Need it for something else?
    handleHrefClick(event) {
        //this.urlListToShow.length = event.currentTarget.dataset.id;
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
}