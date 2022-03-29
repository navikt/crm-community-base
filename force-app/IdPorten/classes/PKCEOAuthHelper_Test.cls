@IsTest 
private class PKCEOAuthHelper_Test {
   
    @IsTest
    private static void testGenerateCodeVerifier(){
        String expectedVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        String codeVerifier=PKCEOAuthHelper.generateCodeVerifier();
        System.assertEquals(expectedVerifier,codeVerifier);
    }

    @IsTest
    private static void testGenerateNonce(){
        String expectedNonce='anw.HT3EPhTDA3j9GAg77ZLEupFB915wEdW2vyyqRgkFFbC11DQAIgQ6jG03kLwIiPY_TFY47h3M2SWFG0jDtyJb4suN8OQffFLqGONqlEhyv2hgLV7r7EfF-LpgSH~a';
        String nonce=PKCEOAuthHelper.generateNonce();
        System.assertEquals(expectedNonce,nonce);
    }

    @IsTest
    private static void testGetCodeChallenge(){
        String codeVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        String expectedChallenge='Wb95F5VolmI3eHN9xfIfNWv8lY-MzKJCfCSaKOuIqas';

        String codeChallenge=PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        System.assertEquals(expectedChallenge,codeChallenge);
    }

    @IsTest
    private static void testGenerateState(){
        String expectedState='zVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSf9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';

        String state=PKCEOAuthHelper.generateState();
        System.assertEquals(expectedState,state);
    }
}
