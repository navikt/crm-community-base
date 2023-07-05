/**
 * @description Test class for testing the `IdPortenAuthProvider` class.
 *
 * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
 * @since 2023-06-27 Created.
 *
 * @group ID-Porten
 * @see IdPortenAuthProvider
 */
@IsTest
private class IdPortenAuthProvider_Test {
    private static final String PROVIDER_NAME = 'IdPortenAuthProvider';
    private static final String CONSUMER_KEY = 'testConsumerKey';
    private static final String CONSUMER_SECRET = 'testConsumerSecret';
    private static final String SCOPE = 'testScope';
    private static final String STATE = 'testState';
    private static final String STATE_TO_PROPOGATE = 'testStateToPropogate';
    private static final String OAUTH_TOKEN = 'testToken';
    private static final String REFRESH_TOKEN = 'refreshToken';
    private static final String LOGIN_ID = 'testLoginId';
    private static final String LOCALE_NAME = 'testLocaleName';
    private static final String AUTHORIZE_ENDPOINT_URL = 'https://dummyhost.no/idporten-oidc-provider/authorize';
    private static final String TOKEN_ENDPOINT_URL = 'https://dummyhost.no/idporten-oidc-provider/authorize';
    private static final String USER_INFO_ENDPOINT_URL = 'https://dummyhost.no/idporten-oidc-provider/userinfo';
    private static final String REDIRECT_URL = 'https://localhost/services/authcallback';

    /**
     * @description Setup auth provider configuration.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     *
     * @return  `Map<String, String>` with auth provider configuration.
     */
    private static Map<String, String> setupAuthProviderConfig() {
        Map<String, String> authProviderConfiguration = new Map<String, String>();
        authProviderConfiguration.put('ConsumerKey__c', CONSUMER_KEY);
        authProviderConfiguration.put('ConsumerSecret__c', CONSUMER_SECRET);
        authProviderConfiguration.put('Scope__c', SCOPE);
        authProviderConfiguration.put('AuthorizeEndpointURL__c', AUTHORIZE_ENDPOINT_URL);
        authProviderConfiguration.put('TokenEndpointURL__c', TOKEN_ENDPOINT_URL);
        authProviderConfiguration.put('UserInfoEndpointURL__c', USER_INFO_ENDPOINT_URL);
        authProviderConfiguration.put('CallbackURL__c', REDIRECT_URL);

        return authProviderConfiguration;
    }

    /**
     * @description Test get custom metadata type method.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-07-05
     */
    @IsTest
    static void testGetCustomMetadataTypePositive() {
        IdPortenAuthProvider authProvider = new IdPortenAuthProvider();

        System.Test.startTest();
        String metadataType = authProvider.getCustomMetadataType();
        System.Test.stopTest();

        System.assertEquals(
            IdPortenAuthProvider.CUSTOM_METADATA_TYPE_API_NAME,
            metadataType,
            'Expected metadata type  name to be same as: "' + IdPortenAuthProvider.CUSTOM_METADATA_TYPE_API_NAME + '".'
        );
    }

    /**
     * @description Test initiate method.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     */
    @IsTest
    static void testInitiateMethodPositive() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

        String codeVerifier = PKCEOAuthHelper.generateCodeVerifier();
        String codeChallenge = PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        String nonce = PKCEOAuthHelper.generateNonce();

        IdPortenAuthProvider authProvider = new IdPortenAuthProvider();
        authProvider.redirectUrl = authProviderConfiguration.get('CallbackURL__c');
        // https://dummyhost.no/idporten-oidc-provider/authorize?client_id={consumerKey}&response_type=code&scope={scope}&redirect_uri={redirectUrl}
        System.Pagereference expectedUrl = new System.Pagereference(
            authProviderConfiguration.get('AuthorizeEndpointURL__c') +
                '?client_id=' +
                authProviderConfiguration.get('ConsumerKey__c') +
                '&response_type=code' +
                '&scope=' +
                authProviderConfiguration.get('Scope__c') +
                '&redirect_uri=' +
                authProviderConfiguration.get('CallbackURL__c') +
                '&state=' +
                STATE_TO_PROPOGATE +
                '&nonce=' +
                nonce +
                '&code_challenge=' +
                codeChallenge +
                '&code_challenge_method=S256'
        );

        System.Test.startTest();
        System.PageReference actualUrl = authProvider.initiate(authProviderConfiguration, STATE_TO_PROPOGATE);
        System.Test.stopTest();

        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl(), 'Expected url to be equal.');
    }

    /**
     * @description Test handle callback method.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     */
    @IsTest
    static void testHandleCallbackMethodPositive() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

        String codeVerifier = PKCEOAuthHelper.generateCodeVerifier();
        String codeChallenge = PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        String nonce = PKCEOAuthHelper.generateNonce();

        CustomAuthProviderState__c customAuthProviderState = new CustomAuthProviderState__c(
            State__c = STATE,
            CodeVerifier__c = codeVerifier,
            Nonce__c = nonce
        );

        insert customAuthProviderState;

        IdPortenAuthProvider authProvider = new IdPortenAuthProvider();
        authProvider.redirectUrl = authProviderConfiguration.get('CallbackURL__c');

        System.Test.setMock(HttpCalloutMock.class, new IdPortenMockHttpResponseGenerator());
        Map<String, String> queryParams = new Map<String, String>();
        queryParams.put('code', 'code');
        queryParams.put('state', STATE);
        Auth.AuthProviderCallbackState callbackState = new Auth.AuthProviderCallbackState(null, null, queryParams);

        System.Test.startTest();
        Auth.AuthProviderTokenResponse actualAuthProvResponse = authProvider.handleCallback(
            authProviderConfiguration,
            callbackState
        );
        System.Test.stopTest();

        Auth.AuthProviderTokenResponse expectedAuthProvResponse = new Auth.AuthProviderTokenResponse(
            PROVIDER_NAME,
            OAUTH_TOKEN,
            REFRESH_TOKEN,
            STATE
        );

        System.assertEquals(
            expectedAuthProvResponse.provider,
            actualAuthProvResponse.provider,
            'Expected provider to be equal.'
        );
        System.assertEquals(
            expectedAuthProvResponse.oauthToken,
            actualAuthProvResponse.oauthToken,
            'Expected oauthToken to be equal.'
        );
        System.assertEquals(
            expectedAuthProvResponse.oauthSecretOrRefreshToken,
            actualAuthProvResponse.oauthSecretOrRefreshToken,
            'Expected oauthSecretOrRefreshToken to be equal.'
        );
        System.assertEquals(
            expectedAuthProvResponse.state,
            actualAuthProvResponse.state,
            'Expected state to be equal.'
        );
    }

    /**
     * @description Test get user info method.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     */
    @IsTest
    static void testGetUserInfoMethodPositive() {
        Map<String, String> authProviderConfiguration = setupAuthProviderConfig();

        IdPortenAuthProvider authProvider = new IdPortenAuthProvider();

        System.Test.setMock(HttpCalloutMock.class, new IdPortenMockHttpResponseGenerator());
        Auth.AuthProviderTokenResponse authProvResponse = new Auth.AuthProviderTokenResponse(
            PROVIDER_NAME,
            OAUTH_TOKEN,
            'sampleOauthSecret',
            STATE
        );

        Test.startTest();
        Auth.UserData actualUserData = authProvider.getUserInfo(authProviderConfiguration, authProvResponse);
        Test.stopTest();

        // public UserData(
        //    String identifier,
        //    String firstName,
        //    String lastName,
        //    String fullName,
        //    String email,
        //    String link,
        //    String userName,
        //    String locale,
        //    String provider,
        //    String siteLoginUrl,
        //    Map<String,String> attributeMap
        // )
        Auth.UserData expectedUserData = new Auth.UserData(
            LOGIN_ID,
            null,
            null,
            null,
            null,
            null,
            null,
            LOCALE_NAME,
            PROVIDER_NAME,
            null,
            null
        );

        System.assertNotEquals(expectedUserData, null, 'Expected userData to not be null.');
        System.assertEquals(expectedUserData.identifier, actualUserData.identifier, 'Expected identifier to be equal.');
        System.assertEquals(expectedUserData.locale, actualUserData.locale, 'Expected locale to be equal.');
        System.assertEquals(expectedUserData.provider, actualUserData.provider, 'Expected provider to be equal.');
    }

    /**
     * @description Http callout mock implementation for testing the Http callout from the
     * ID-Porten auth provider (`IdPortenAuthProvider`) class.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     */
    public class IdPortenMockHttpResponseGenerator implements HttpCalloutMock {
        String body = '';
        public HttpResponse respond(HttpRequest request) {
            if (request.getMethod() == 'GET') {
                if (request.getEndpoint().contains(USER_INFO_ENDPOINT_URL)) {
                    // {"pid":"12345678901","locale":"nb"}
                    body = '{' + '    "pid" : "' + LOGIN_ID + '",' + '  "locale" : "' + LOCALE_NAME + '"' + '}';
                }
            } else if (request.getMethod() == 'POST') {
                if (request.getEndpoint().contains(TOKEN_ENDPOINT_URL)) {
                    // {"access_token":"my_access_token"}
                    body = '{ "access_token" : "' + OAUTH_TOKEN + '" }';
                }
            }

            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setHeader('Content-Type', 'application/json');
            response.setBody(body);

            return response;
        }
    }
}
