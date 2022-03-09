public with sharing class CodeVerifierApiCallout {
   
    public static HttpResponse storeCodeVerifier(String codeVerifier, String nonce, String state, String clientId, String clientSecret){
        String accessToken = getAccessToken(clientId,clientSecret);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/idporten/codeverifier');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('POST');
        req.setBody('{"codeVerifier":"' + codeVerifier + '","nonce":"' + nonce + '","state":"' + state + '"}');                     
        HTTPResponse res = http.send(req);
        return res;
    }

    public static IdPortenCache getCodeVerifier(String state,String clientId, String clientSecret){
        String accessToken = getAccessToken(clientId,clientSecret);
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/idporten/codeverifier?state=' + state);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setMethod('GET');
        HTTPResponse res = http.send(req);
        return (IdPortenCache) System.JSON.deserialize(res.getBody(),IdPortenCache.class);
    }

    private static String getAccessToken(String clientId, String clientSecret){
        if(Test.isRunningTest()){
            return 'access';
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:IdPortenCodeVerifier');
        req.setMethod('POST');
        req.setBody('grant_type=password&client_id=' + clientId + '&client_secret=' + clientSecret +'&username={!$Credential.Username}&password={!$Credential.Password}');

        HTTPResponse res = http.send(req);
        return getTokenValueFromResponse(res.getBody(), 'access_token');
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
