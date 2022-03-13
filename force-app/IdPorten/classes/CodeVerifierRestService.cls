@RestResource(urlMapping='/idporten/codeverifier/*')
global with sharing class CodeVerifierRestService {

    @HttpPost
    global static void storeCodeVerifier(String codeVerifier, String nonce, String state) {
        IdPortenCache__c cache=new IdPortenCache__c();
        cache.CodeVerifier__c=codeVerifier;
        cache.Nonce__c=nonce;
        cache.State__c=state;
        cache.Type__c='Code Verifier';
        system.debug(codeVerifier);
        system.debug(nonce);
        system.debug(state);
        insert cache;
    }

    @HttpGet
    global static IdPortenCache getCodeVerifier() {
        String state = getRequestParam('state');
        for(IdPortenCache__c cache:[SELECT State__c, Nonce__c, CodeVerifier__c FROM IdPortenCache__c WHERE CreatedDate> :Datetime.now().addMinutes(-15) AND Type__c='Code Verifier' ORDER BY CreatedDate DESC]){
            if(cache.State__c==state){
                IdPortenCache idPortenCache=new IdPortenCache();
                idPortenCache.codeVerifier=cache.CodeVerifier__c;
                idportenCache.nonce=cache.Nonce__c;
                delete cache;
                return idPortenCache;
            }
        }
        return null;
    }

    private static String getRequestParam(String paramName) {
        RestRequest request = RestContext.request;
        return request.params.containsKey(paramName) ? request.params.get(paramName) : null;
    }
}