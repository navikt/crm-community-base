@
IsTest
private class IdPortenAuth_Test {

    private static final String CONSUMER_KEY ='key';
    private static final String CONSUMER_SECRET ='secret';
    private static final String ARC_VALUES ='arc';
    private static final String CODE_VERIFIER_KEY='cvkey';
    private static final String CODE_VERIFIER_SECRET='cvsecret';
    private static final String AUTHORIZE_ENDPOINT_URL='https://auth';
    private static final String TOKEN_ENDPOINT_URL='https://token';
    private static final String URL_SUFFIX='suffix';
    private static final String USER_INFO_ENDPOINT_URL='https://userinfo';
    private static final String SCOPE='openid';
    private static final String REDIRECT_URL='https://callback';
    private static final String CODE_VERIFIER='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
    
    private static Map<String,String> setupAuthProviderConfig () {
        Map<String,String> authProviderConfiguration = new Map<String,String>();
        authProviderConfiguration.put('ConsumerKey__c',CONSUMER_KEY);
        authProviderConfiguration.put('ConsumerSecret__c',CONSUMER_SECRET);
        authProviderConfiguration.put('AcrValues__c', ARC_VALUES);
        authProviderConfiguration.put('AuthorizeEndpointUrl__c', AUTHORIZE_ENDPOINT_URL);
        authProviderConfiguration.put('CodeVerifierKey__c', CODE_VERIFIER_KEY);
        authProviderConfiguration.put('CodeVerifierSecret__c', CODE_VERIFIER_SECRET);
        authProviderConfiguration.put('TokenEndpointUrl__c',TOKEN_ENDPOINT_URL);
        authProviderConfiguration.put('UrlSuffix__c',URL_SUFFIX);
        authProviderConfiguration.put('UserInfoEndpointUrl__c',USER_INFO_ENDPOINT_URL);
        return authProviderConfiguration;
    }

    static testMethod void testInitiateMethod() {
        Test.setMock(HttpCalloutMock.class, new CodeVerifierPostMock());
        String stateToPropogate = 'mocktestState';
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
        IdPortenAuth auth = new IdPortenAuth();

        String codeChallenge=PKCEOAuthHelper.getCodeChallenge(CODE_VERIFIER);        
        PageReference expectedUrl =  new PageReference(AUTHORIZE_ENDPOINT_URL + '?client_id='+ 
                                            CONSUMER_KEY + '&acr_values=' + ARC_VALUES + '&response_type=code&scope=' + scope + '&redirect_uri='+ 
                                            REDIRECT_URL + '&state=' + 
                                            stateToPropogate + '&code_challenge=' + codeChallenge  + '&code_challenge_method=S256&ui_locales=nb');

        PageReference actualUrl = auth.initiate(authProviderConfiguration, stateToPropogate);
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
    }

    static testMethod void testHandleCallback() {
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
        IdPortenAuth auth = new IdPortenAuth();
        Test.setMock(HttpCalloutMock.class, new GetCodeVerifierMock());
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        Map<String,String> queryParams = new Map<String,String>();
        queryParams.put('code','code');
        queryParams.put('state','mocktestState');
        Auth.AuthProviderCallbackState cbState = new Auth.AuthProviderCallbackState(null,null,queryParams);
        Auth.AuthProviderTokenResponse actualAuthProvResponse = auth.handleCallback(authProviderConfiguration, cbState);
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('ID-porten', 'access', 'refresh', null);
        
        System.assertEquals(expectedAuthProvResponse.provider, actualAuthProvResponse.provider);
        System.assertEquals(expectedAuthProvResponse.oauthToken, actualAuthProvResponse.oauthToken);
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, actualAuthProvResponse.oauthSecretOrRefreshToken);
        System.assertEquals('mocktestState', actualAuthProvResponse.state);
        System.assertEquals('QsSodfCDUpKRIYQb_fL2KUd-7UUBxEnQz7mcJxMX344', auth.sid);
 }

 static testMethod void testGetUserInfo() {
    Map<String,String> authProviderConfiguration = setupAuthProviderConfig();
    IdPortenAuth auth = new IdPortenAuth();
               
    Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

    Auth.AuthProviderTokenResponse response = new Auth.AuthProviderTokenResponse('ID-porten', 'access' ,'sampleOauthSecret', 'mocktestState');
    Auth.UserData actualUserData = auth.getUserInfo(authProviderConfiguration, response) ;
    
    System.assertEquals('ID-porten', actualUserData.provider);
    }

    public class TokenEndpointMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            String idToken='eyJraWQiOiJ2UHBaZW9HOGRkTHpmdHMxLWxnc3VnOHNyYVd3bW04dHhJaGJ3Y1h3R01JIiwiYWxnIjoiUlMyNTYifQ.eyJhdF9oYXNoIjoiSGs1TDE4WVVDTVZHbjFLNFBpckY2QSIsInN1YiI6Ii10c01LdWxFNUZHQUU1WkhRRUVlLWNsT2ZqS1VheGpYVmNXc2RsaHFBRWM9IiwiYW1yIjpbIkJhbmtJRCJdLCJpc3MiOiJodHRwczpcL1wvb2lkYy12ZXIyLmRpZmkubm9cL2lkcG9ydGVuLW9pZGMtcHJvdmlkZXJcLyIsInBpZCI6IjE2MTIwMTAxMTgxIiwibG9jYWxlIjoibmIiLCJzaWQiOiJRc1NvZGZDRFVwS1JJWVFiX2ZMMktVZC03VVVCeEVuUXo3bWNKeE1YMzQ0IiwiYXVkIjoiYTA2OTY2MTItZWZjNC00NmU5LWE3YzktYmZmNjU2ZTU1NGMyIiwiYWNyIjoiTGV2ZWw0IiwiYXV0aF90aW1lIjoxNjQ2MjI1ODIyLCJleHAiOjE2NDYyMjcxNjMsImlhdCI6MTY0NjIyNzA0MywianRpIjoiTjVSTUpCZmFieU5OSWRlQWlyYzFlQmYxRlhfVVA0eGNrNVlQSjJ1aFBCdyJ9.0uyhTX5EWknLBc2U3OGpBK9bmsfNPV6V8pQdYDnSa6jsMyqMErn8rPVwpwiY82alkQLuzdEVb6xPJuCWqx3gwXCyIdK-jdPUU0ck9qIs5zvmzBTaegIU2TEhAMHB-q21JvTRe2LdJCSUuZRyUddhEwbxTU0gPv14ktJSMG8_69Qvqqc3DjNg_vhGD2J3Yf4V3aXcL1LqlsXVrkqk1p41dQ1iwAsSTAlEHhWHaXjbal60849dxguZZhdtx-fCJ8aobGZr1puicoE0GVZTaO0flGsCQtaGr4gwmFcTnqd0iymAfez2WkaxjprluT1m8-1ZVAf_wYDc9gwsR-liwQiuQg';
            res.setBody('{"access_token":"access","refresh_token":"refresh", "id_token":"' + idToken + '"}'); 
            res.setStatusCode(200);
            return res; 
        }
    }
}
