/**
 * @description Custom Salesforce Auth Provider for ID-Porten.
 * It implements the use of code challange - PKCE (Proof Key for Code Exchange)
 * for enhanced security.
 *
 * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
 * @since 2023-06-27 Created.
 *
 * @see [License](https://github.com/navikt/crm-community-base/blob/master/LICENSE)
 * @see [Github](https://github.com/navikt/crm-community-base)
 *
 * @group ID-Porten
 *
 * @see [ID-Porten](https://docs.digdir.no/docs/idporten/idporten/idporten_overordnet)
 * @see [Create a Custom Authentication Provider Plug-in](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/authproviderplugin.htm)
 * @see [Auth.AuthProviderPluginClass Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderPluginClass.htm#apex_Auth_AuthProviderPluginClass_refresh)
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class IdPortenAuthProvider extends Auth.AuthProviderPluginClass {
    /**
     * @description Provider Name = class name.
     */
    public static final String PROVIDER_NAME = 'IdPortenAuthProvider';
    /**
     * @description Custom Metadata Type name assosiated with this custom auth provider class.
     */
    public static final String CUSTOM_METADATA_TYPE_API_NAME = 'IdPortenAuthProvider__mdt';

    /**
     * @description Use this URL for the endpoint that the authentication provider calls back to for configuration.
     */
    public String redirectUrl;

    /**
     * @description The API name of the custom metadata type that contains the configuration for this auth provider.
     */
    private String customMetadataTypeApiName = CUSTOM_METADATA_TYPE_API_NAME;
    /**
     * @description The consumer key.
     */
    private String consumerKey;
    /**
     * @description The consumer secret.
     */
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
     * @return The API name of the custom metadata type that contains the configuration for this auth provider.
     *
     * @see [Auth.AuthProviderPluginClass.getCustomMetadataType method](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderPluginClass.htm#apex_Auth_AuthProviderPluginClass_getCustomMetadataType)
     * @see [Custom Metadata Types](https://help.salesforce.com/s/articleView?id=sf.custommetadatatypes_overview.htm&type=5)
     */
    global String getCustomMetadataType() {
        return this.customMetadataTypeApiName;
    }

    /**
     * @description Returns the URL where the user is redirected for authentication.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-27
     *
     * @param authProviderConfiguration The configuration for this auth provider.
     * @param stateToPropagate The state to propagate to the callback URL.
     * @return `System.PageReference` The URL where the user is redirected for authentication.
     *
     * @see [Auth.AuthProviderPluginClass.initiate method](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderPluginClass.htm#apex_Auth_AuthProviderPluginClass_initiate)
     * @see [System.PageReference class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_system_pagereference.htm#apex_system_pagereference)
     */
    @SuppressWarnings('PMD.ApexOpenRedirect')
    global System.PageReference initiate(Map<string, string> authProviderConfiguration, String stateToPropagate) {
        this.authorizeEndpointUrl = authProviderConfiguration.get('AuthorizeEndpointURL__c');
        this.redirectUrl = authProviderConfiguration.get('CallbackURL__c');
        this.consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        this.scope = authProviderConfiguration.get('Scope__c');

        String codeVerifier = PKCEOAuthHelper.generateCodeVerifier();
        String codeChallenge = PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        String nonce = PKCEOAuthHelper.generateNonce();

        CustomAuthProviderState__c customAuthProviderState = new CustomAuthProviderState__c(
            State__c = stateToPropagate,
            CodeVerifier__c = codeVerifier,
            Nonce__c = nonce
        );

        insert customAuthProviderState;

        // https://{endpoint base url}//authorize?client_id={consumerKey}&response_type=code&scope={scope}&redirect_uri={redirectUrl}&state={stateToPropagate}&nonce={nonce}&code_challenge={codeChallenge}&code_challenge_method=S256
        String url =
            authorizeEndpointUrl +
            '?client_id=' +
            consumerKey +
            '&response_type=code&scope=' +
            scope +
            '&redirect_uri=' +
            redirectUrl +
            '&state=' +
            stateToPropagate +
            '&nonce=' +
            nonce +
            '&code_challenge=' +
            codeChallenge +
            '&code_challenge_method=S256';

        return new System.PageReference(url);
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
     * @return `Auth.AuthProviderTokenResponse` The token response.
     *
     * @see [Auth.AuthProviderPluginClass.handleCallback method](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderPluginClass.htm#apex_Auth_AuthProviderPluginClass_handleCallback)
     * @see [AuthProviderCallbackState Class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderCallbackState.htm#apex_class_Auth_AuthProviderCallbackState)
     * @see [Auth.AuthProviderTokenResponse class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderTokenResponse.htm#apex_class_Auth_AuthProviderTokenResponse)
     */
    global Auth.AuthProviderTokenResponse handleCallback(
        Map<string, string> authProviderConfiguration,
        Auth.AuthProviderCallbackState state
    ) {
        this.tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointURL__c');
        this.redirectUrl = authProviderConfiguration.get('CallbackURL__c');
        this.consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        this.consumerSecret = authProviderConfiguration.get('ConsumerSecret__c');

        Map<String, String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String stateToPropagate = queryParams.get('state');

        CustomAuthProviderState__c customAuthProviderState = [
            SELECT Id, State__c, CodeVerifier__c, Nonce__c
            FROM CustomAuthProviderState__c
            WHERE State__c = :stateToPropagate
            LIMIT 1
        ];

        HttpRequest request = new HttpRequest();
        // https://{endpoint base url}/token?code={code}&state={sfdcState}&grant_type=authorization_code&client_id={consumerKey}&client_secret={consumerSecret}&redirect_uri={redirectUrl}&code_challenge{customAuthProviderState.CodeVerifier__c}
        String url =
            this.tokenEndpointUrl +
            '?code=' +
            code +
            '&state=' +
            stateToPropagate +
            '&grant_type=authorization_code&client_id=' +
            this.consumerKey +
            '&client_secret=' +
            this.consumerSecret +
            '&redirect_uri=' +
            this.redirectUrl +
            '&code_verifier=' +
            customAuthProviderState.CodeVerifier__c;
        request.setEndpoint(url);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setMethod('POST');

        Http http = new Http();
        HttpResponse response = http.send(request);

        String responseBody = response.getBody();
        TokenResponseWrapper tokenResponse = (TokenResponseWrapper) JSON.deserialize(
            responseBody,
            TokenResponseWrapper.class
        );

        // Can't get this to work, and can't check what the tokenResponse.id_token is giving us.
        // It should have given us the nonce back as part of the id token value.
        // would be nice to verify that it is the same nonce as we sendt with the initial request.
        //JWTClaims claims = decodeIdToken(tokenResponse.id_token);
        //String nonce = customAuthProviderState.Nonce__c;

        /*if (claims.nonce != nonce) {
            throw new IdPortenAuthProviderException('Nonce validation failed!');
        }*/

        return new Auth.AuthProviderTokenResponse(
            PROVIDER_NAME,
            tokenResponse.access_token,
            'refreshToken',
            stateToPropagate
        );
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
     *
     * @see [Auth.AuthProviderPluginClass.getUserInfo method](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderPluginClass.htm#apex_Auth_AuthProviderPluginClass_getUserInfo)
     * @see [Auth.AuthProviderTokenResponse class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_AuthProviderTokenResponse.htm#apex_class_Auth_AuthProviderTokenResponse)
     * @see [Auth.UserData class](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Auth_UserData.htm)
     */
    @SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
    global Auth.UserData getUserInfo(
        Map<string, string> authProviderConfiguration,
        Auth.AuthProviderTokenResponse tokenResponse
    ) {
        this.userInfoEndpointUrl = authProviderConfiguration.get('UserInfoEndpointURL__c');

        // https://{endpoint base url}/userinfo
        HttpRequest request = new HttpRequest();
        request.setEndpoint(this.userInfoEndpointUrl);
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

        // We will not use all the fields from the Auth.UserData, since we only recives sid, pid
        // and local in the response from ID-Porte.
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
            userInfoResponse.pid,
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
     * @description The Id Porten Auth Provider Exeption `IdPortenAuthProviderException` class.
     * Used for throwing an exception inside the `IdPortenAuthProvider`class.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     */
    public class IdPortenAuthProviderException extends Exception {
    }

    /**
     * @description The Token Response Wrapper used when retrieving the token information from
     * the token endpoint.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     *
     * @see [ID-Porten Token Response](https://docs.digdir.no/docs/idporten/oidc/oidc_protocol_token.html#response)
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
     * @description The User Info Response Wrapper used when retrieving the user info from the
     * user info endpoint.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-28
     *
     * @see [ID-Porten User Info Response](https://docs.digdir.no/docs/idporten/oidc/oidc_protocol_userinfo.html#response)
     */
    public class UserInfoResponseWrapper {
        public String locale;
        public String sub;
        public String pid;
    }

    /**
     * @description Decodes the id token and returns the claims.
     * It is copy of the implementation in `IdPortenAuthUtil` class.
     * We may delete it if we can't get the nonce in the id token to work.
     * And/or utilze the original implementation in `IdPortenAuthUtil` class instad.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-30
     *
     * @param encodedJWT The encoded Id Token.
     * @return `JWTClaims` containing the decoded claims.
     *
     * @see IdPortenAuthUtil.JWTClaims
     */
    /* Disabled for now because it is not working as intended.
    private static JWTClaims decodeIdToken(String encodedJWT) {
        try {
            Integer headerLength = encodedJWT.indexOf('.');
            Integer claimsLength = encodedJWT.lastIndexOf('.');
            String jwtClaims = encodedJWT.mid(headerLength + 1, claimsLength - headerLength - 1);

            JWTClaims claimsDeserialized = (JWTClaims) Json.deserialize(
                EncodingUtil.base64Decode(jwtClaims).toString(),
                JWTClaims.class
            );
            return claimsDeserialized;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error decoding JWT: ' + e.getMessage());
        }
        return new JWTClaims();
    }*/

    /**
     * @description The claims in the JWT token.
     *
     * @author Kenneth Soerensen <kenneth.sorensen@nav.no>
     * @since 2023-06-30
     */
    /* Disabled for now because it is not working as intended.
    private class JWTClaims {
        String sub;
        String aud;
        String acr;
        Integer auth_time;
        String amr;
        String iss;
        String pid;
        Integer exp;
        String locale;
        Integer iat;
        String nonce;
        String jti;
    }*/
}
