public with sharing class NavLoginServiceController {
    private final String LOGINSERVICE_URL_PROD = 'https://loginservice.nav.no';
    private final String LOGINSERVICE_URL_PREPROD = 'https://login.ekstern.dev.nav.no/oauth2';
    public PageReference redirect() {
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');

        String currentUrl = getCommunityBaseUrl() + '/apex/NavLoginService';
        String redirectUrl = LOGINSERVICE_URL_PROD;
        if (!currentUrl.contains('nav.no')) {
            redirectUrl = LOGINSERVICE_URL_PREPROD;
        }

        if (retUrl != null) {
            //redirect to NAV loginservice and cache ret url

            Cookie retUrlCookie = new Cookie('retUrl', retUrl, null, 1800, true);
            ApexPages.currentPage().setCookies(new List<Cookie>{ retUrlCookie });
            redirectUrl += '/login?redirect=' + currentUrl;
            pageReference pg = new pageReference(redirectUrl);
            return pg.setRedirect(true);
        }

        //we asume user are comming from Loginservice
        //redirect to retUrl in current community
        Cookie retUrlCookie = ApexPages.currentPage().getCookies().get('retUrl');
        if (retUrlCookie != null) {
            retUrl = retUrlCookie.getValue();
            if (retUrl != null) {
                pageReference pg = new pageReference(retUrl);
                return pg.setRedirect(true);
            }
        }
        pageReference pg = new pageReference(redirectUrl);
        return pg.setRedirect(true);
    }

    private static string getCommunityBaseUrl() {
        String communityBaseUrl = Network.getLoginUrl(Network.getNetworkId());
        if (Test.isRunningTest()) {
            communityBaseUrl = 'https://test-comunity.com/login';
        }
        communityBaseUrl = communityBaseUrl.replace('/login', '');
        return communityBaseUrl;
    }
}
