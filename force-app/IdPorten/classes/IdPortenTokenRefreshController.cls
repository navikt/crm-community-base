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
}
