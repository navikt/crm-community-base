public with sharing class IdPortenTokenRefreshController {
    public PageReference redirect() {
        String redirectUrl = ApexPages.currentPage().getParameters().get('redirectUrl');

        if (redirectUrl != null) {
            getNewRefreshToken(redirectUrl);
            pageReference pg = new pageReference(redirectUrl);
            return pg.setRedirect(true);
        }

        return null;
    }

    private static void getNewRefreshToken(String redirectUrl) {
        Cookie refreshTokenCookie = ApexPages.currentPage().getCookies().get('refreshToken');
        String newRefreshToken;
        String accessToken;
        IdPortenAuthUtil util = new IdPortenAuthUtil();
        if (refreshTokenCookie != null) {
            IdPortenAuthUtil.TokenResponse tokenResponse = util.getTokensFromRefreshToken(
                refreshTokenCookie.getValue()
            );
            newRefreshToken = tokenResponse?.refreshToken;
            accessToken = tokenResponse?.accessToken;
        } else {
            LoggerUtility logger = new LoggerUtility();
            logger.error('Refresh token cookie not found', null, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }
        if (!String.isBlank(newRefreshToken)) {
            Integer userInfoResponseCode = util.getUserInfo(accessToken);
            LoggerUtility logger = new LoggerUtility();
            logger.info(
                'User info ' +
                ' ' +
                userInfoResponseCode.toString() +
                accessToken,
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
            logger.publishSynch();

            util.extendSession();
        }
        refreshTokenCookie = new Cookie('refreshToken', newRefreshToken, null, 1800, true);
        Cookie redirectUrlCookie = new Cookie('redirectUrl', redirectUrl, null, 1800, true);
        ApexPages.currentPage().setCookies(new List<Cookie>{ refreshTokenCookie, redirectUrlCookie });
    }
}
