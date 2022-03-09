@IsTest
private class CodeVerifierRestService_Test {
    
    @IsTest
    private static void testStoreCodeVerifier(){
        CodeVerifierRestService.storeCodeVerifier('verifier','nonce','mockState');
        System.assertEquals(1,[SELECT COUNT() FROM IdPortenCache__c WHERE Type__c='Code Verifier']);
    }

    @IsTest
    private static void testGetCodeVerifier(){
        CodeVerifierRestService.storeCodeVerifier('verifier','nonce','mockState');

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/idporten/codeverifier';
        req.addParameter('state','mockState');
            
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        IdPortenCache cache=CodeVerifierRestService.getCodeVerifier();
        Test.stopTest();
        
        System.assertEquals('verifier',cache.codeVerifier);
        System.assertEquals(0,[SELECT COUNT() FROM IdPortenCache__c WHERE Type__c='Code Verifier'], 'Record is deleted');
    }
}
