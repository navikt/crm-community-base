@IsTest 
private class PKCEOAuthHelper_Test {
   
    @IsTest
    private static void testGenerateCodeVerifier(){
        String expectedVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        String codeVerifier=PKCEOAuthHelper.generateCodeVerifier();
        System.assertEquals(expectedVerifier,codeVerifier);
    }

    @IsTest
    private static void getCodeChallenge(){
        String codeVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        String expectedChallenge='Wb95F5VolmI3eHN9xfIfNWv8lY-MzKJCfCSaKOuIqas';

        String codeChallenge=PKCEOAuthHelper.getCodeChallenge(codeVerifier);
        System.assertEquals(expectedChallenge,codeChallenge);
    }
}
