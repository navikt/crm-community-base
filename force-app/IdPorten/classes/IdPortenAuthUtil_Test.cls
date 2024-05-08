@IsTest
private with sharing class IdPortenAuthUtil_Test {
    private static final String CONSUMER_KEY = 'key';
    private static final String CONSUMER_SECRET = 'secret';
    private static final String ARC_VALUES = 'arc';
    private static final String AUTHORIZE_ENDPOINT_URL = 'https://auth';
    private static final String TOKEN_ENDPOINT_URL = 'https://token';
    private static final String SCOPE = 'openid';
    private static final String REDIRECT_URL = 'https://callback';
    private static final String CODE_VERIFIER = 'kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
    private static final String STATE = 'zVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSf9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
    private static final String NONCE = 'anw.HT3EPhTDA3j9GAg77ZLEupFB915wEdW2vyyqRgkFFbC11DQAIgQ6jG03kLwIiPY_TFY47h3M2SWFG0jDtyJb4suN8OQffFLqGONqlEhyv2hgLV7r7EfF-LpgSH~a';

    @IsTest
    private static void testInitiate() {
        IdPortenAuthUtil authUtil = new IdPortenAuthUtil();
        String codeChallenge = PKCEOAuthHelper.getCodeChallenge(CODE_VERIFIER);
        String expectedUrl =
            AUTHORIZE_ENDPOINT_URL +
            '?client_id=' +
            CONSUMER_KEY +
            '&acr_values=' +
            ARC_VALUES +
            '&scope=' +
            scope +
            '&redirect_uri=' +
            REDIRECT_URL +
            '&response_type=code&state=' +
            STATE +
            '&code_challenge=' +
            codeChallenge +
            '&code_challenge_method=S256&ui_locales=nb&nonce=' +
            NONCE;

        IdPortenAuthUtil.AuthResponse response = authUtil.initiate();
        System.assertEquals(expectedUrl, response.initiateUrl);
    }

    @IsTest
    private static void testStoreSid() {
        Id userId = '0052o000009GmW3AAK';
        String sid = 'test-sid';

        new IdPortenAuthUtil().storeSid(sid, userId);

        System.assertEquals(
            1,
            [SELECT COUNT() FROM IdPortenCache__c WHERE Name = :sid AND UserId__c = :userId],
            'SID is created as cache record'
        );
    }

    @IsTest
    private static void testStoreSid_whenInvalidData() {
        Id userId = '0052o000009GmW3AAK';
        String sid = '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';

        new IdPortenAuthUtil().storeSid(sid, userId);

        System.assertEquals(
            1,
            [SELECT COUNT() FROM Application_Log__c WHERE Source_Class__c = 'IdPortenAuthUtil'],
            'Error thrown due to max field length error'
        );
    }

    @IsTest
    private static void testStoreSid_whenSidIsEmpty() {
        Id userId = '0052o000009GmW3AAK';
        String sid = null;

        new IdPortenAuthUtil().storeSid(sid, userId);
        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenAuthUtil'
        ];
        System.assertEquals(1, errorLogs.size(), 'Throw 1 error');
        System.assertEquals('Finner ikke SID fra ID-token', errorLogs[0].Log_Message__c);
    }

    @IsTest
    private static void testGetSidFromIdToken() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());
        String sid = new IdPortenAuthUtil().getSidFromIdToken('code', CODE_VERIFIER, 'noncetest');
        System.assertEquals('QsSodfCDUpKRIYQb_fL2KUd-7UUBxEnQz7mcJxMX344', sid);
    }

    @IsTest
    private static void testGetSidFromIdToken_whenIdPortenApiReturnError() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMockError());
        String sid = new IdPortenAuthUtil().getSidFromIdToken('code', CODE_VERIFIER, 'noncetest');
        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenAuthUtil'
        ];
        System.assertEquals(null, sid, 'No SID is returned');
        System.assertEquals(1, errorLogs.size(), 'Throw 1 error');
        System.assertEquals('Kunne ikke hente id token Error', errorLogs[0].Log_Message__c);
    }

    @IsTest
    private static void testGetSidFromIdToken_whenNonceDoNotMatch() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());
        String sid = new IdPortenAuthUtil().getSidFromIdToken('code', CODE_VERIFIER, 'anotherNonce');
        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenAuthUtil'
        ];
        System.assertEquals(null, sid, 'No SID is returned');
        System.assertEquals(1, errorLogs.size(), 'Throw 1 error');
        System.assertEquals('Nonce samsvarer ikke', errorLogs[0].Log_Message__c);
    }

    public class TokenEndpointMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            String idToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdF9oYXNoIjoiSGs1TDE4WVVDTVZHbjFLNFBpckY2QSIsInN1YiI6Ii10c01LdWxFNUZHQUU1WkhRRUVlLWNsT2ZqS1VheGpYVmNXc2RsaHFBRWM9IiwiYW1yIjpbIkJhbmtJRCJdLCJpc3MiOiJodHRwczovL29pZGMtdmVyMi5kaWZpLm5vL2lkcG9ydGVuLW9pZGMtcHJvdmlkZXIvIiwicGlkIjoiMTYxMjAxMDExODEiLCJsb2NhbGUiOiJuYiIsInNpZCI6IlFzU29kZkNEVXBLUklZUWJfZkwyS1VkLTdVVUJ4RW5RejdtY0p4TVgzNDQiLCJhdWQiOiJhMDY5NjYxMi1lZmM0LTQ2ZTktYTdjOS1iZmY2NTZlNTU0YzIiLCJhY3IiOiJMZXZlbDQiLCJhdXRoX3RpbWUiOjE2NDYyMjU4MjIsImV4cCI6MTY0NjIyNzE2MywiaWF0IjoxNjQ2MjI3MDQzLCJub25jZSI6Im5vbmNldGVzdCIsImp0aSI6Ik41Uk1KQmZhYnlOTklkZUFpcmMxZUJmMUZYX1VQNHhjazVZUEoydWhQQncifQ.5-MEpzms1cH97aAFVM2bNATADrdSiWxt1s_ZtiOgJ1w';
            res.setBody('{"access_token":"access","refresh_token":"refresh", "id_token":"' + idToken + '"}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class TokenEndpointMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('Error');
            res.setStatusCode(500);
            return res;
        }
    }
}
