@RestResource(urlMapping='/idporten/codeverifier/*')
global with sharing class CodeVerifierRestService {

    @HttpPost
    global static void storeCodeVerifier(String codeVerifier, String state) {
        IdPortenCache__c cache=new IdPortenCache__c();
        cache.CodeVerifier__c=codeVerifier;
        cache.State__c=state;
        cache.Type__c='Code Verifier';
        insert cache;
    }

    @HttpGet
    global static string getCodeVerifier() {
        String state = getRequestParam('state');
        for(IdPortenCache__c cache:[SELECT State__c, CodeVerifier__c FROM IdPortenCache__c WHERE CreatedDate> :Datetime.now().addMinutes(-1) AND Type__c='Code Verifier' ORDER BY CreatedDate DESC]){
            if(cache.State__c==state){
                String codeVerifier=cache.CodeVerifier__c;
                delete cache;
                return codeVerifier;
            }
        }
        return null;
    }

    private static String getRequestParam(String paramName) {
        RestRequest request = RestContext.request;
        return request.params.containsKey(paramName) ? request.params.get(paramName) : null;
    }
}