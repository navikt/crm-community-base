@IsTest
private class CodeVerifierApiCallout_Test {
   
    @IsTest
    private static void testStoreCodeVerifier(){
        Test.setMock(HttpCalloutMock.class, new CodeVerifierPostMock());

        HttpResponse res= CodeVerifierApiCallout.storeCodeVerifier('verifier', 'state','clientId', 'secret');
        System.assertEquals(200,res.getStatusCode());
    }

    @IsTest
    private static void testGetCodeVerifier(){
        Test.setMock(HttpCalloutMock.class, new GetCodeVerifierMock());

        String codeverifier= CodeVerifierApiCallout.getCodeVerifier('state','clientId', 'secret');
        String expectedVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        System.assertEquals(expectedVerifier,codeVerifier);
    }

}
