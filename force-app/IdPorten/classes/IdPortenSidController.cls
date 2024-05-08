public with sharing class IdPortenSidController {
    private Cookie stateCookie;
    private Cookie nonceCookie;
    private Cookie codeVerifierCookie;
    private Cookie retUrlCookie;

    public PageReference redirect() {
        String code = apexpages.currentPage().getParameters().get('code');
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        String redirectUrl = ApexPages.currentPage().getParameters().get('redirectUrl');

        //stop login flow when mobile app
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if (userAgent != null && userAgent.contains('SalesforceMobileSDK')) {
            return Auth.SessionManagement.finishLoginFlow(retUrl);
        }

        //get new ID porten token from refresh token
        if (redirectUrl != null) {
            getNewRefreshToken(redirectUrl);
            pageReference pg = new pageReference(redirectUrl);
            return pg.setRedirect(true);
        }

        //initiate
        if (code == null) {
            IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
            IdPortenAuthUtil.AuthResponse authResponse = authUtil.initiate();
            codeVerifierCookie = new Cookie('codeverifier', authResponse.codeVerifier, null, 1800, true);
            stateCookie = new Cookie('state', authResponse.state, null, 1800, true);
            nonceCookie = new Cookie('nonce', authResponse.nonce, null, 1800, true);

            //cache retUrl to be used in finishLoginFlow
            String relativeRetUrl = getRelativeRetUrl(retUrl);
            retUrlCookie = new Cookie('retUrl', relativeRetUrl, null, 1800, true);

            ApexPages.currentPage()
                .setCookies(new List<Cookie>{ codeVerifierCookie, stateCookie, nonceCookie, retUrlCookie });
            pageReference pg = new pageReference(authResponse.initiateUrl);
            return pg.setRedirect(true);
        }

        //handle callback
        String state = apexpages.currentPage().getParameters().get('state');

        codeVerifierCookie = ApexPages.currentPage().getCookies().get('codeVerifier');
        stateCookie = ApexPages.currentPage().getCookies().get('state');
        nonceCookie = ApexPages.currentPage().getCookies().get('nonce');

        if (codeVerifierCookie == null || stateCookie == null || nonceCookie == null) {
            LoggerUtility logger = new LoggerUtility();
            logger.error('Cookies er ikke satt', null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        String codeVerifierFromCookie = codeVerifierCookie.getValue();
        String stateFromCookie = stateCookie.getValue();
        String nonceFromCookie = nonceCookie.getValue();

        if (state == null || state != stateFromCookie) {
            LoggerUtility logger = new LoggerUtility();
            logger.error('State samsvarer ikke', null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        if (nonceFromCookie == null) {
            LoggerUtility logger = new LoggerUtility();
            logger.error('Nonce er blank', null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        if (codeVerifierFromCookie == null) {
            LoggerUtility logger = new LoggerUtility();
            logger.error('Code verifier er blank', null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
        IdPortenAuthUtil.TokenResponse tokenResponse = authUtil.getSidFromIdToken(
            code,
            codeVerifierFromCookie,
            nonceFromCookie
        );
        String sid = tokenResponse?.sid;
        String refreshToken = tokenResponse?.refreshToken;
        Cookie refreshTokenCookie = new Cookie('refreshToken', refreshToken, null, 1800, true);
        ApexPages.currentPage().setCookies(new List<Cookie>{ refreshTokenCookie });

        Id userId = UserInfo.getUserId();
        authUtil.storeSid(sid, userId);
        return finishLoginFlow();
    }

    private static PageReference finishLoginFlow() {
        List<String> communitiesUsingNewDecorator = new List<String>{
            '0DB2o000000Ug9I',
            '0DB2o000000Ug9D',
            '0DB0E0000005HX9',
            '0DB7U000000TN3uWAG',
            '0DB7U0000004C9wWAE'
        };

        Cookie retUrlCookie = ApexPages.currentPage().getCookies().get('retUrl');
        if (retUrlCookie == null) {
            LoggerUtility logger = new LoggerUtility();
            logger.error('Kunne ikke hente ret ur fra cookie', null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return Auth.SessionManagement.finishLoginFlow();
        }
        String retUrl = retUrlCookie.getValue();

        if (retUrl != null && communitiesUsingNewDecorator.contains(Network.getNetworkId())) {
            //redirect to loginservice to be able to use new decorator
            return Auth.SessionManagement.finishLoginFlow('/apex/NavLoginService?retUrl=' + retUrl);
        }

        if (retUrl != null) {
            return Auth.SessionManagement.finishLoginFlow(retUrl);
        }
        return Auth.SessionManagement.finishLoginFlow();
    }

    private static void getNewRefreshToken(String redirectUrl) {
        Cookie refreshTokenCookie = ApexPages.currentPage().getCookies().get('refreshToken');
        String newRefreshToken;
        if (refreshTokenCookie != null) {
            IdPortenAuthUtil.TokenResponse tokenResponse = new IdPortenAuthUtil()
                .getTokensFromRefreshToken(refreshTokenCookie.getValue());
            newRefreshToken = tokenResponse?.refreshToken;
        } else {
            LoggerUtility logger = new LoggerUtility();
            logger.error('Refresh token cookie not found', null, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }

        refreshTokenCookie = new Cookie('refreshToken', newRefreshToken, null, 1800, true);
        Cookie redirectUrlCookie = new Cookie('redirectUrl', redirectUrl, null, 1800, true);
        ApexPages.currentPage().setCookies(new List<Cookie>{ refreshTokenCookie, redirectUrlCookie });
    }

    private static String getRelativeRetUrl(String retUrl) {
        String communityBaseUrl = Network.getLoginUrl(Network.getNetworkId());
        if (Test.isRunningTest()) {
            communityBaseUrl = 'https://test-comunity.com/login';
        }
        communityBaseUrl = communityBaseUrl.replace('/login', '');
        //remove base url from retUrl
        if (retUrl != null) {
            retUrl = retUrl.replace(communityBaseUrl, '');
            //remove spaces
            retUrl = retUrl.replaceAll(' ', '%20');
        }
        return retUrl;
    }
}
