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
    private static final String NONCE='anw.HT3EPhTDA3j9GAg77ZLEupFB915wEdW2vyyqRgkFFbC11DQAIgQ6jG03kLwIiPY_TFY47h3M2SWFG0jDtyJb4suN8OQffFLqGONqlEhyv2hgLV7r7EfF-LpgSH~a';
    
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
                                            stateToPropogate + '&code_challenge=' + codeChallenge  + '&code_challenge_method=S256&ui_locales=nb&nonce=' + NONCE);

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
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse('ID-porten', 'access', 'refresh', 'mockTestState');
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
            String nonce='noncetest';
            String codeVerifier='verifier';
            String idToken='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdF9oYXNoIjoiSGs1TDE4WVVDTVZHbjFLNFBpckY2QSIsInN1YiI6Ii10c01LdWxFNUZHQUU1WkhRRUVlLWNsT2ZqS1VheGpYVmNXc2RsaHFBRWM9IiwiYW1yIjpbIkJhbmtJRCJdLCJpc3MiOiJodHRwczovL29pZGMtdmVyMi5kaWZpLm5vL2lkcG9ydGVuLW9pZGMtcHJvdmlkZXIvIiwicGlkIjoiMTYxMjAxMDExODEiLCJsb2NhbGUiOiJuYiIsInNpZCI6IlFzU29kZkNEVXBLUklZUWJfZkwyS1VkLTdVVUJ4RW5RejdtY0p4TVgzNDQiLCJhdWQiOiJhMDY5NjYxMi1lZmM0LTQ2ZTktYTdjOS1iZmY2NTZlNTU0YzIiLCJhY3IiOiJMZXZlbDQiLCJhdXRoX3RpbWUiOjE2NDYyMjU4MjIsImV4cCI6MTY0NjIyNzE2MywiaWF0IjoxNjQ2MjI3MDQzLCJub25jZSI6Im5vbmNldGVzdCIsImp0aSI6Ik41Uk1KQmZhYnlOTklkZUFpcmMxZUJmMUZYX1VQNHhjazVZUEoydWhQQncifQ.5-MEpzms1cH97aAFVM2bNATADrdSiWxt1s_ZtiOgJ1w';
            res.setBody('{"access_token":"access","refresh_token":"refresh", "id_token":"' + idToken + '","codeVerifier":"' + codeVerifier + '","nonce":"' + nonce +'"}'); 
            
            res.setStatusCode(200);
            return res; 
        }
    }
}
