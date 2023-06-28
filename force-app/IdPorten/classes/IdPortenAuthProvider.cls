/**
 * @description Custom Salesforce Auth Provider for ID-Porten
 *
 * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
 * @since 2023-06-27 Created.
 *
 * @see [License](https://github.com/navikt/crm-community-base/blob/master/LICENSE)
 * @see [Github](https://github.com/navikt/crm-community-base)
 *
 * @group ID-Porten
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class IdPortenAuthProvider extends Auth.AuthProviderPluginClass {
    public static final String PROVIDER_NAME = 'IdPortenAuthProvider';
    public static final String CUSTOM_METADATA_TYPE_API_NAME = 'IdPortenAuthProvider__mdt';

    /**
     * @description Use this URL for the endpoint that the authentication provider calls back to for configuration.
     */
    public String redirectUrl;

    /**
     * @description The API name of the custom metadata type that contains the configuration for this auth provider.
     */
    private String customMetadataTypeApiName = CUSTOM_METADATA_TYPE_API_NAME;
    private String consumerKey;
    private String consumerSecret;
    /**
     * @description The URL that the application redirect to for authentication and authorization.
     */
    private String authorizeEndpointUrl;
    /**
     * @description The URL that the application uses to get an access token from the authorization server (ID-Porten) using GET (verb) request.
     */
    private String tokenEndpointUrl;
    /**
     * @description The URL that the application uses to get user information from the authorization server (ID-Porten).
     */
    private String userInfoEndpointUrl;
    /**
     * @description The scope to be used for the authentication request.
     */
    private String scope;

    /**
     * @description Constructor
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     *
     * @param customMetadataTypeApiName The API name of the custom metadata type that contains the configuration for this auth provider.
     */
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    /**
     * @description Returns the URL where the user is redirected for authentication.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     *
     * @param authProviderConfiguration The configuration for this auth provider.
     * @param stateToPropagate The state to propagate to the callback URL.
     */
    @SuppressWarnings('PMD.ApexOpenRedirect')
    global PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
        authorizeEndpointUrl = authProviderConfiguration.get('AuthorizeEndpointUrl__c');
        redirectUrl = authProviderConfiguration.get('RedirectUrl__c');
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        scope = authProviderConfiguration.get('Scope__c');

        // https://oidc-ver2.difi.no/idporten-oidc-provider/authorize?client_id={consumerKey}&response_type=code&scope={scope}&redirect_uri={redirectUrl}
        String url =
            authorizeEndpointUrl +
            '?client_id=' +
            consumerKey +
            '&response_type=code&scope=' +
            scope +
            '&redirect_uri=' +
            redirectUrl;
        return new PageReference(url);
    }

    /**
     * @description Uses the authentication provider’s supported authentication protocol to return
     * an OAuth access token, OAuth secret or refresh token, and the state passed in when the
     * request for the current user was initiated.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     *
     * @param authProviderConfiguration The configuration for this auth provider.
     * @param state The state parameter from the callback request.
     * @return  `Auth.AuthProviderTokenResponse` The token response.
     */
    global Auth.AuthProviderTokenResponse handleCallback(
        Map<string, string> authProviderConfiguration,
        Auth.AuthProviderCallbackState state
    ) {
        tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointUrl__c');
        redirectUrl = authProviderConfiguration.get('RedirectUrl__c');
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        consumerSecret = authProviderConfiguration.get('ConsumerSecret__c');

        Map<String, String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');

        HttpRequest request = new HttpRequest();
        // https://oidc-ver2.difi.no/idporten-oidc-provider/token?code={code}&state={sfdcState}&grant_type=authorization_code&client_id={consumerKey}&client_secret={consumerSecret}&redirect_uri={redirectUrl}
        String url =
            tokenEndpointUrl +
            '?code=' +
            code +
            '&state=' +
            sfdcState +
            '&grant_type=authorization_code&client_id=' +
            consumerKey +
            '&client_secret=' +
            consumerSecret +
            'redirect_uri=' +
            redirectUrl;
        request.setEndpoint(url);
        request.setHeader('Accept', 'application/json');
        request.setMethod('POST');

        Http http = new Http();
        HttpResponse response = http.send(request);

        String responseBody = response.getBody();
        TokenResponseWrapper tokenResponse = (TokenResponseWrapper) JSON.deserialize(
            responseBody,
            TokenResponseWrapper.class
        );

        return new Auth.AuthProviderTokenResponse(PROVIDER_NAME, tokenResponse.access_token, 'refreshToken', sfdcState);
    }

    /**
     * @description Returns the user information for the current user.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     *
     * @param authProviderConfiguration The configuration for this auth provider.
     * @param tokenResponse The token response.
     * @return  `Auth.UserData` The user data.
     */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    global Auth.UserData getUserInfo(
        Map<string, string> authProviderConfiguration,
        Auth.AuthProviderTokenResponse tokenResponse
    ) {
        userInfoEndpointUrl = authProviderConfiguration.get('UserInfoEndpointUrl__c');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(userInfoEndpointUrl);
        request.setHeader('Accept', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + tokenResponse.oauthToken);
        request.setMethod('GET');

        Http http = new Http();
        HttpResponse response = http.send(request);

        String responseBody = response.getBody();
        UserInfoResponseWrapper userInfoResponse = (UserInfoResponseWrapper) JSON.deserialize(
            responseBody,
            UserInfoResponseWrapper.class
        );

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
        Auth.UserData userData = new Auth.UserData(
            userInfoResponse.sub,
            null,
            null,
            null,
            null,
            null,
            null,
            userInfoResponse.locale,
            PROVIDER_NAME,
            null,
            null
        );

        return userData;
    }

    /**
     * @description
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     *
     */
    @SuppressWarnings('PMD.VariableNamingConventions')
    public class TokenResponseWrapper {
        public String access_token;
        public String expires_in;
        public String id_token;
        public String refresh_token;
        public String scope;
    }

    /**
     * @description
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     *
     */
    public class UserInfoResponseWrapper {
        public String sub;
        public String pid;
        public String locale;
    }
}
