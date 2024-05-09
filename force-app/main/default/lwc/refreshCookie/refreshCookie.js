import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const visualForcePage = 'IdPortenTokenRefresh';
export default class RefreshCookie extends NavigationMixin(LightningElement) {
    connectedCallback() {
        const cookie = this.findCookie('apex__redirectUrl');
        if (cookie === '' || cookie !== window.location.href) {
            this.navigateToRefreshPage();
        }
    }

    // Stolen from https://www.w3schools.com/js/js_cookies.asp
    findCookie(cname) {
        let name = cname + '=';
        let decodedCookie = decodeURIComponent(document.cookie);
        let ca = decodedCookie.split(';');
        for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) === ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) === 0) {
                return c.substring(name.length, c.length);
            }
        }
        return '';
    }

    navigateToRefreshPage() {
        const currentSite = window.location.href;

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/' + visualForcePage + '?redirectUrl=' + encodeURIComponent(currentSite)
            }
        }).then((url) => {
            const urlWithoutSiteEnding = url.replace('/s/', '/');
            window.location.href = urlWithoutSiteEnding;
        });
    }
}
