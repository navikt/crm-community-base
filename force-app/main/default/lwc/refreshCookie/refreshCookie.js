import { LightningElement } from 'lwc';

const visualForcePage = 'IdPortenTokenRefresh';

// Stolen from https://www.w3schools.com/js/js_cookies.asp
const findCookie = (cname) => {
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
};

const navigateToRefreshPage = () => {
    const currentSite = window.location.href;

    const splitSite = currentSite.split('/s/');
    window.location.href =
        splitSite[0] + '/apex/' + visualForcePage + '?redirectUrl=' + encodeURIComponent(currentSite);
};

// Gotten from https://salesforce.stackexchange.com/questions/167523/detect-community-builder-context
const isInSitePreview = () => {
    return ['sitepreview', 'livepreview', 'live-preview', 'live.', '.builder.'].some((substring) =>
        document.URL.includes(substring)
    );
};
let hasRun = false;

export default class RefreshCookie extends LightningElement {
    // eslint-disable-next-line constructor-super
    constructor() {
        if (hasRun) {
            return;
        }
        const cookie = findCookie('apex__redirectUrl');
        if ((cookie === '' || cookie !== window.location.href) && !isInSitePreview()) {
            hasRun = true;
            navigateToRefreshPage();
        } else {
            super();
        }
    }
}
