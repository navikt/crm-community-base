global class IdPorten extends Auth.AuthProviderPluginClass {
    private String authorizeEndpointUrl;
    private String consumerKey;
    private String consumerSecret;
    private String tokenEndpointUrl;
    private String userInfoEndpointUrl;
    private String customMetadataTypeApiName='ID_porten__mdt';
    private String scope='openid';
    private String redirectUrl;
    private String acrValues;
    private String sid;
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        system.debug('init');
        authorizeEndpointUrl = authProviderConfiguration.get('AuthorizeEndpointUrl__c');
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        acrValues = authProviderConfiguration.get('AcrValues__c');
        redirectUrl = authProviderConfiguration.get('RedirectUrl__c');
        String codeVerifier=stateToPropagate.subString(0,128);
        
        String codeChallenge=PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        
        //get Salesforce access token
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:IdPortenCodeVerifier');
        req.setMethod('POST');
        String codeVerifierKey=authProviderConfiguration.get('CodeVerifierKey__c');
        String codeVerifierSecret = authProviderConfiguration.get('CodeVerifierSecret__c');
        system.debug(codeVerifierKey);
        system.debug(codeVerifierSecret);
        req.setBody('grant_type=password&client_id=' + codeVerifierKey + '&client_secret=' + codeVerifierSecret +'&username={!$Credential.Username}&password={!$Credential.Password}');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String accessToken = getTokenValueFromResponse(res.getBody(), 'access_token');
        System.debug(res.getBody());


        //store code verifier
        http = new Http();
        req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/idporten/codeverifier');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setBody('{"codeVerifier":"' + codeVerifier + '","state":"' + stateToPropagate + '"}');                   
        http = new Http();
        res = http.send(req);
        system.debug(res.getBody());
        String url =  authorizeEndpointUrl + '?client_id='+ consumerKey +'&acr_values=' + acrValues + '&scope=' + scope +'&redirect_uri='+ redirectUrl + '&response_type=code&state=' + stateToPropagate +'&code_challenge=' + codeChallenge + '&code_challenge_method=S256&ui_locales=nb';
        return new Pagereference(url);
     }

     global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        consumerSecret = authProviderConfiguration.get('ConsumerSecret__c');
        tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointUrl__c');
        redirectUrl = authProviderConfiguration.get('RedirectUrl__c');
        String encodedRedirectUrl=EncodingUtil.urlEncode(redirectUrl,'UTF-8');     
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');    
        String codeVerifier=sfdcState.subString(0,128);
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
        return new Auth.AuthProviderTokenResponse('ID-porten', accessToken, refreshToken, sfdcState);
        
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
        String networkId = authProviderConfiguration.get('NetworkId__c');
        
        Map<String,String> provMap = new Map<String,String>();
        provMap.put('sub', sub);
        provMap.put('pid', pid);
        provMap.put('sid', sid);
        provMap.put('sfdc_networkid', networkId);
        
        
        return new Auth.UserData(sub, null, null, null, null,
             null, null, null, 'IdPorten', null, provMap);
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

    private class JWTClaims {
        String sid;
        String pid;
    }

}
