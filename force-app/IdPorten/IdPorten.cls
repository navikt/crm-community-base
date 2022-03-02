global class IdPorten extends Auth.AuthProviderPluginClass {
    private String authorizeEndpointUrl;
    private String consumerKey;
    private String consumerSecret;
    private String tokenEndpointUrl;
    private String userInfoEndpointUrl;
    private String customMetadataTypeApiName='ID_porten__mdt';
    private String scope='openid';
    private String redirectUrl='https://sandbox-business-flow-6622-17f40b22d6d.cs88.force.com/services/authcallback/ID_porten_level_4';
    private String acrValues;
    private String codeVerifier='1BkMwOpYkl8AdGpEohP98_qz7vaEck1XRo50wspo35khhFbXgt.57y81ziTssrAlFb~~1SRsplbpTNAulcgUrDWeWEvR_J4WY1ZAmxmnrEWFaCrKVRnfed_pRF0bqa66';
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        authorizeEndpointUrl = authProviderConfiguration.get('AuthorizeEndpointUrl__c');
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        acrValues = authProviderConfiguration.get('AcrValues__c');
        String codeChallenge=PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        String url =  authorizeEndpointUrl + '?client_id='+ consumerKey +'&acr_values=' + acrValues + '&scope=' + scope +'&redirect_uri='+ redirectUrl + '&response_type=code&state=' + stateToPropagate +'&code_challenge=' + codeChallenge + '&code_challenge_method=S256&ui_locales=nb';
        return new PageReference(url);
     }

     global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        consumerKey = authProviderConfiguration.get('ConsumerKey__c');
        consumerSecret = authProviderConfiguration.get('ConsumerSecret__c');
        tokenEndpointUrl = authProviderConfiguration.get('TokenEndpointUrl__c');
        String encodedRedirectUrl=EncodingUtil.urlEncode(redirectUrl,'UTF-8');     
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');     
        HttpRequest req = new HttpRequest();
        //String url = tokenEndpointUrl;+'?grant_type=authorization_code&redirect_url=' + redirectUrl + '&code=' + code + '&code_challenge=' + codeChallenge;
        req.setEndpoint(tokenEndpointUrl);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody('grant_type=authorization_code&redirect_url=' + encodedRedirectUrl + '&code=' + code + '&client_id='+ consumerKey + '&client_secret=' + consumerSecret + '&code_verifier=' + codeVerifier);
                   
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String accessToken = getTokenValueFromResponse(res.getBody(), 'access_token');
        String refreshToken = getTokenValueFromResponse(res.getBody(), 'refresh_token');
        String idToken = getTokenValueFromResponse(res.getBody(), 'id_token');
        system.debug('**idToken ' + idToken);
        return new Auth.AuthProviderTokenResponse('IdPorten', accessToken, 'refreshToken', sfdcState);
        
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
        system.debug(responseBody);
        String id = getTokenValueFromResponse(responseBody, 'LoginId');
        String fname = getTokenValueFromResponse(responseBody, 'FirstName');
        String lname = getTokenValueFromResponse(responseBody, 'LastName');
        String flname = fname + ' ' + lname;
        String uname = getTokenValueFromResponse(responseBody, 'EmailAddress');
        String locale = getTokenValueFromResponse(responseBody, 'LocaleName');
        Map<String,String> provMap = new Map<String,String>();
        provMap.put('what1', 'noidea1');
        provMap.put('what2', 'noidea2');
        return new Auth.UserData(id, fname, lname, flname, uname,
             'what', locale, null, 'IdPorten', null, provMap);
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
}
