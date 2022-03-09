public class PKCEOAuthHelper {

    public static String generateCodeVerifier() { 
        String codeVerifier=generateRandomString(128);
        if(Test.isRunningTest()){
            return 'kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        }
        return codeVerifier;
    }

    public static String generateNonce(){
        String nonce=generateRandomString(128);
        if(Test.isRunningTest()){
            return 'anw.HT3EPhTDA3j9GAg77ZLEupFB915wEdW2vyyqRgkFFbC11DQAIgQ6jG03kLwIiPY_TFY47h3M2SWFG0jDtyJb4suN8OQffFLqGONqlEhyv2hgLV7r7EfF-LpgSH~a';
        }
        return nonce;
    }

    private static String generateRandomString(Integer length){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz.~';
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

    public static String getCodeChallenge(string codeVerifier){
        Blob sha256 = Crypto.generateDigest('SHA-256', Blob.valueOf(codeVerifier));
        return  base64URLencode(sha256);
    }
    
    private static String base64URLencode(Blob input){
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while ( output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
    
    
    }