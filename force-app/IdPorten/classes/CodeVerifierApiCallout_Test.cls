@IsTest
private class CodeVerifierApiCallout_Test {
   
    @IsTest
    private static void testStoreCodeVerifier(){
        Test.setMock(HttpCalloutMock.class, new CodeVerifierPostMock());

        HttpResponse res= CodeVerifierApiCallout.storeCodeVerifier('verifier','nonce', 'state','clientId', 'secret');
        System.assertEquals(200,res.getStatusCode());
    }

    @IsTest
    private static void testGetCodeVerifier(){
        Test.setMock(HttpCalloutMock.class, new GetCodeVerifierMock());

        IdPortenCache cache = CodeVerifierApiCallout.getCodeVerifier('state','clientId', 'secret');
        String expectedVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        System.assertEquals(expectedVerifier,cache.codeVerifier);

        String expectedNonce='anw.HT3EPhTDA3j9GAg77ZLEupFB915wEdW2vyyqRgkFFbC11DQAIgQ6jG03kLwIiPY_TFY47h3M2SWFG0jDtyJb4suN8OQffFLqGONqlEhyv2hgLV7r7EfF-LpgSH~a';
        System.assertEquals(expectedNonce,cache.nonce);
    }

}
