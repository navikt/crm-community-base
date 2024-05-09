import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RefreshCookie extends NavigationMixin(LightningElement) {
    connectedCallback() {
        const cookie = this.findCookie('apex__nonce');
        if (cookie === '') {
            console.log('No cookie, sending to refresh');
            this.navigateToRefreshPage();
        } else {
            console.log('Had cookie, lucky');
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
        document.cookie = 'redirectUrl=' + currentSite;

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/IdPortenTokenRefresh'
            }
        }).then((url) => {
            console.log(url);
            const a = url.replace('/s/', '/');
            console.log(a);
            window.location.href = a;
        });
    }
}
