@RestResource(urlMapping='/idporten/codeverifier/*')
global with sharing class CodeVerifierRestService {

    @HttpPost
    global static void storeCodeVerifier(String codeVerifier, String nonce, String state) {
        try{
            IdPortenCache__c cache=new IdPortenCache__c();
            cache.CodeVerifier__c=codeVerifier;
            cache.Nonce__c=nonce;
            cache.State__c=state;
            cache.Type__c='Code Verifier';
            insert cache;
        	}   
        	catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
        }
        
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
        //unable to find cache. Log as error
        LoggerUtility logger = new LoggerUtility();
        logger.error('Unable to find cache record ' + state,null, CRM_ApplicationDomain.Domain.NKS);
        logger.publishSynch();
        return null;
    }

    private static String getRequestParam(String paramName) {
        RestRequest request = RestContext.request;
        return request.params.containsKey(paramName) ? request.params.get(paramName) : null;
    }
}