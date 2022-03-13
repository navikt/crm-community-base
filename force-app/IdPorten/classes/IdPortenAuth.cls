global class IdPortenAuth extends Auth.AuthProviderPluginClass {
    private String authorizeEndpointUrl;
    private String consumerKey;
    private String consumerSecret;
    private String tokenEndpointUrl;
    private String userInfoEndpointUrl;
    private String customMetadataTypeApiName='ID_porten__mdt';
    private String scope='openid';
    private String acrValues;
    @TestVisible
    private String sid;
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {

        authorizeEndpointUrl = authProviderConfiguration.get('AuthorizeEndpointUrl__c');
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        acrValues = authProviderConfiguration.get('AcrValues__c');
        String codeVerifier=PKCEOAuthHelper.generateCodeVerifier();
        String codeChallenge=PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        String nonce=PKCEOAuthHelper.generateNonce();
        String codeVerifierKey=authProviderConfiguration.get('CodeVerifierKey__c');
        String codeVerifierSecret = authProviderConfiguration.get('CodeVerifierSecret__c');
        CodeVerifierApiCallout.storeCodeVerifier(codeVerifier, nonce, stateToPropagate, codeVerifierKey, codeVerifierSecret);
        String redirectUrl=getRedirectUrl(authProviderConfiguration.get('UrlSuffix__c'));
        system.debug(redirectUrl);
        String url =  authorizeEndpointUrl + '?client_id='+ consumerKey +'&acr_values=' + acrValues + '&scope=' + scope +'&redirect_uri='+ redirectUrl + '&response_type=code&state=' + stateToPropagate +'&code_challenge=' + codeChallenge + '&code_challenge_method=S256&ui_locales=nb&nonce=' + nonce;
        return new Pagereference(url);
     }

     global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        consumerSecret = authProviderConfiguration.get('ConsumerSecret__c');
        tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointUrl__c');
        String redirectUrl = getRedirectUrl(authProviderConfiguration.get('UrlSuffix__c'));
        String encodedRedirectUrl=EncodingUtil.urlEncode(redirectUrl,'UTF-8');     
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');  
        String codeVerifierKey=authProviderConfiguration.get('CodeVerifierKey__c');
        String codeVerifierSecret = authProviderConfiguration.get('CodeVerifierSecret__c');  
       
        //chceck state and get code verifer and nonce
        IdPortenCache cache=CodeVerifierApiCallout.getCodeVerifier(sfdcState,codeVerifierKey,codeVerifierSecret);
        String codeVerifier=cache.codeVerifier;
        String nonce=cache.nonce;

        //check sate code verifer and nonce are found
        if(sfdcState==null || codeVerifier==null || nonce==null){
            return null;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpointUrl);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody('grant_type=authorization_code&redirect_url=' + encodedRedirectUrl + '&code=' + code + '&client_id='+ consumerKey + '&client_secret=' + consumerSecret + '&code_verifier=' + codeVerifier);
                   
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String accessToken = getTokenValueFromResponse(res.getBody(), 'access_token');
        String refreshToken = getTokenValueFromResponse(res.getBody(), 'refresh_token');
        String idToken = getTokenValueFromResponse(res.getBody(), 'id_token');
        JWTClaims decodedIdToken=decodeIdToken(idToken);
        sid=decodedIdToken.sid;

        if(decodedIdToken.nonce!=null && decodedIdToken.nonce==nonce){
            return new Auth.AuthProviderTokenResponse('ID-porten', accessToken, refreshToken, sfdcState);
        }
        return null;
     }

     global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        String token = response.oauthToken;
        HttpRequest req = new HttpRequest();
        userInfoEndpointUrl = authProviderConfiguration.get('UserInfoEndpointUrl__c');
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setEndpoint(userInfoEndpointUrl);
        req.setHeader('Content-Type','application/xml');
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        String sub = getTokenValueFromResponse(responseBody, 'sub');
        String pid = getTokenValueFromResponse(responseBody, 'pid');
        
        Map<String,String> provMap = new Map<String,String>();
        provMap.put('sub', sub);
        provMap.put('pid', pid);
        provMap.put('sid', sid);
        provMap.put('sfdc_networkid', Network.getNetworkId());
        
        
        return new Auth.UserData(sub, null, null, null, null,
             null, null, null, 'ID-porten', null, provMap);
     }

     private static String getTokenValueFromResponse(String response, String token) {
        JSONParser parser = JSON.createParser(response);
        String tokenValue = '';
        while (parser.nextToken() != null) {
            if (parser.getText() == token) {
                parser.nextToken();
                tokenValue = parser.getText();
            }
        }

        return tokenValue;
    }

    private static JWTClaims decodeIdToken(String encodedJWT){
        Integer headerLength = encodedJWT.indexOf('.');
        Integer claimsLength = encodedJWT.lastIndexOf('.');
        String jwtClaims = encodedJWT.mid(headerLength + 1, claimsLength - headerLength - 1);

        JWTClaims claimsDeserialized = (JWTClaims) Json.deserialize(
            EncodingUtil.base64Decode(jwtClaims).toString(),
            JWTClaims.class
        );
        return claimsDeserialized;
    }

    private static String getRedirectUrl(String urlSuffix){
        if(Test.isRunningTest()){
            return 'https://callback';
        }
        String redirectUrl=Network.getLoginUrl(Network.getNetworkId());
        redirectUrl=redirectUrl.replace('/login', '/services/authcallback/');
        redirectUrl+=urlSuffix;

        return redirectUrl;
    }
    private class JWTClaims {
        String sid;
        String nonce;
    }

}
