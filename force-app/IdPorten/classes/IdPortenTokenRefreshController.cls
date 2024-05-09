public with sharing class IdPortenTokenRefreshController {
    private static final Integer SESSION_DURATION_IN_MINUTES = 24;

    public PageReference redirect() {
        Cookie stateCookie;
        Cookie nonceCookie;
        Cookie codeVerifierCookie;
        Cookie retUrlCookie;
        Cookie redirectUrlCookie;
        String code = apexpages.currentPage().getParameters().get('code');
        String redirectUrl = ApexPages.currentPage().getParameters().get('redirectUrl');

        //don't refresh if mobile app
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if (userAgent != null && userAgent.contains('SalesforceMobileSDK')) {
            pageReference pg = new pageReference(redirectUrl);
            return pg.setRedirect(true);
        }

        //initiate
        if (code == null) {
            Cookie refreshTokenCookie = new Cookie('redirectUrl', redirectUrl, null, 1800, true);
            redirectUrlCookie = new Cookie('redirectUrl', 'temp', null, 1800, true);

            IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
            IdPortenAuthUtil.AuthResponse authResponse = authUtil.initiate();
            codeVerifierCookie = new Cookie('codeverifier', authResponse.codeVerifier, null, 1800, true);
            stateCookie = new Cookie('state', authResponse.state, null, 1800, true);
            nonceCookie = new Cookie('nonce', authResponse.nonce, null, 1800, true);

            ApexPages.currentPage()
                .setCookies(
                    new List<Cookie>{
                        codeVerifierCookie,
                        stateCookie,
                        nonceCookie,
                        redirectUrlCookie,
                        refreshTokenCookie
                    }
                );
            pageReference pg = new pageReference(authResponse.initiateUrl);
            return pg.setRedirect(true);
        }

        //handle callback
        try {
            String state = apexpages.currentPage().getParameters().get('state');

            codeVerifierCookie = ApexPages.currentPage().getCookies().get('codeVerifier');
            stateCookie = ApexPages.currentPage().getCookies().get('state');
            nonceCookie = ApexPages.currentPage().getCookies().get('nonce');
            redirectUrlCookie = ApexPages.currentPage().getCookies().get('redirectUrl');

            if (codeVerifierCookie == null || stateCookie == null || nonceCookie == null) {
                LoggerUtility logger = new LoggerUtility();
                logger.error('Cookies er ikke satt', null, CRM_ApplicationDomain.Domain.NKS);
                logger.publishSynch();
            }

            String codeVerifierFromCookie = codeVerifierCookie.getValue();
            String stateFromCookie = stateCookie.getValue();
            String nonceFromCookie = nonceCookie.getValue();

            if (state == null || state != stateFromCookie) {
                LoggerUtility logger = new LoggerUtility();
                logger.error('State samsvarer ikke', null, CRM_ApplicationDomain.Domain.NKS);
                logger.publishSynch();
            }

            if (nonceFromCookie == null) {
                LoggerUtility logger = new LoggerUtility();
                logger.error('Nonce er blank', null, CRM_ApplicationDomain.Domain.NKS);
                logger.publishSynch();
            }

            if (codeVerifierFromCookie == null) {
                LoggerUtility logger = new LoggerUtility();
                logger.error('Code verifier er blank', null, CRM_ApplicationDomain.Domain.NKS);
                logger.publishSynch();
            }

            IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
            IdPortenAuthUtil.TokenResponse tokenResponse = authUtil.getSidFromIdToken(
                code,
                codeVerifierFromCookie,
                nonceFromCookie
            );
            String sid = tokenResponse?.sid;
            extendSession(sid);

            String redirectUrlFromCookie = redirectUrlCookie.getValue();
            pageReference pg = new pageReference(redirectUrlFromCookie);
            return pg.setRedirect(true);
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }
        return null;
    }

    private void extendSession(String sid) {
        List<IdPortenCache__c> listOfCache = [
            SELECT Id
            FROM IdPortenCache__c
            WHERE UserId__c = :UserInfo.getUserId() AND Name = :sid
        ];
        for (IdPortenCache__c cache : listOfCache) {
            cache.ExpirationTime__c = DateTime.Now().addMinutes(SESSION_DURATION_IN_MINUTES);
        }

        try {
            update listOfCache;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }
    }
}
