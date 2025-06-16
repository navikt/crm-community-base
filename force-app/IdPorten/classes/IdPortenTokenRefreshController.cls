public with sharing class IdPortenTokenRefreshController {
    private static final Integer SESSION_DURATION_IN_MINUTES = 24;

    public PageReference validateAndRedirect() {
        // Code from https://salesforce.stackexchange.com/questions/256499/how-can-i-determine-if-the-org-that-im-currently-connected-to-is-a-scratch-org
        Organization org = [
            SELECT IsSandbox, TrialExpirationDate
            FROM Organization
        ];
        Boolean isScratchOrg =
            org?.IsSandbox && org?.TrialExpirationDate != null;

        if (isScratchOrg == true) {
            String redirectUrl = ApexPages.currentPage()
                .getParameters()
                .get('redirectUrl');
            ApexPages.currentPage()
                .setCookies(
                    new List<Cookie>{
                        new Cookie('redirectUrl', redirectUrl, null, 900, true)
                    }
                );
            pageReference pgTester = new pageReference(redirectUrl);
            return pgTester.setRedirect(true);
        }
        return redirect();
    }

    public PageReference redirect() {
        Cookie stateCookie;
        Cookie nonceCookie;
        Cookie codeVerifierCookie;
        Cookie retUrlCookie;
        Cookie redirectUrlCookie;
        String code = apexpages.currentPage().getParameters().get('code');
        String redirectUrl = ApexPages.currentPage()
            .getParameters()
            .get('redirectUrl');

        //don't refresh if mobile app
        String userAgent = ApexPages.currentPage()
            .getHeaders()
            .get('USER-AGENT');
        if (userAgent != null && userAgent.contains('SalesforceMobileSDK')) {
            pageReference pg = new pageReference(redirectUrl);
            return pg.setRedirect(true);
        }

        //initiate
        if (code == null) {
            redirectUrlCookie = new Cookie(
                'redirectUrl',
                redirectUrl,
                null,
                900,
                true
            );

            IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
            IdPortenAuthUtil.AuthResponse authResponse = authUtil.initiate(
                'IdPortenTokenRefresh'
            );
            codeVerifierCookie = new Cookie(
                'codeverifier',
                authResponse.codeVerifier,
                null,
                1800,
                true
            );
            stateCookie = new Cookie(
                'state',
                authResponse.state,
                null,
                1800,
                true
            );
            nonceCookie = new Cookie(
                'nonce',
                authResponse.nonce,
                null,
                1800,
                true
            );

            ApexPages.currentPage()
                .setCookies(
                    new List<Cookie>{
                        codeVerifierCookie,
                        stateCookie,
                        nonceCookie,
                        redirectUrlCookie
                    }
                );
            pageReference pg = new pageReference(authResponse.initiateUrl);
            return pg.setRedirect(true);
        }

        //handle callback
        try {
            String state = apexpages.currentPage().getParameters().get('state');

            codeVerifierCookie = ApexPages.currentPage()
                .getCookies()
                .get('codeVerifier');
            stateCookie = ApexPages.currentPage().getCookies().get('state');
            nonceCookie = ApexPages.currentPage().getCookies().get('nonce');
            redirectUrlCookie = ApexPages.currentPage()
                .getCookies()
                .get('redirectUrl');

            if (redirectUrlCookie == null) {
                throw new IdPortenException('Redirect URL cookie is not set.');
            }
            String redirectUrlFromCookie = redirectUrlCookie.getValue();
            pageReference pg = new pageReference(redirectUrlFromCookie);

            if (
                codeVerifierCookie == null ||
                stateCookie == null ||
                nonceCookie == null
            ) {
                LoggerUtility logger = new LoggerUtility();
                logger.error(
                    'Cookies er ikke satt',
                    null,
                    CRM_ApplicationDomain.Domain.NKS
                );
                logger.publishSynch();
                return pg.setRedirect(true);
            }

            String codeVerifierFromCookie = codeVerifierCookie.getValue();
            String stateFromCookie = stateCookie.getValue();
            String nonceFromCookie = nonceCookie.getValue();

            if (state == null || state != stateFromCookie) {
                LoggerUtility logger = new LoggerUtility();
                logger.error(
                    'State samsvarer ikke',
                    null,
                    CRM_ApplicationDomain.Domain.NKS
                );
                logger.publishSynch();
                return pg.setRedirect(true);
            }

            IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
            IdPortenAuthUtil.TokenResponse tokenResponse = authUtil.getSidFromIdToken(
                code,
                codeVerifierFromCookie,
                nonceFromCookie,
                'IdPortenTokenRefresh'
            );
            String sid = tokenResponse?.sid;
            if (sid != null && !String.isBlank(sid)) {
                authUtil.extendSession();
            }
            return pg.setRedirect(true);
        } catch (IdPortenException e) {
            LoggerUtility logger = new LoggerUtility(
                CRM_ApplicationDomain.Domain.PLATFORCE,
                'IdPorten'
            );

            if (
                e.getMessage()
                    .equalsIgnoreCase('Redirect URL cookie is not set.')
            ) {
                logger.logMessage(
                    LoggerUtility.LogLevel.ERROR,
                    '',
                    '',
                    e.getMessage(),
                    e.getStackTraceString(),
                    null
                );
            } else {
                logger.exception(e);
            }
            logger.publishSynch();
        } catch (CalloutException e) {
            LoggerUtility logger = new LoggerUtility(
                CRM_ApplicationDomain.Domain.PLATFORCE,
                'IdPorten'
            );
            if (e.getMessage().contains('Read timed out')) {
                // No need for Critical or error on timeout
                logger.logMessage(
                    LoggerUtility.LogLevel.WARNING,
                    '',
                    '',
                    e.getMessage(),
                    e.getStackTraceString(),
                    null
                );
            } else {
                logger.exception(e);
            }
            logger.publishSynch();
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility(
                CRM_ApplicationDomain.Domain.PLATFORCE,
                'IdPorten'
            );
            logger.exception(e);
            logger.publishSynch();
        }
        return null;
    }
}
