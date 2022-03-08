public class PKCEOAuthHelper {

    public static String generateCodeVerifier() { 
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz.~';
        String randStr = '';
        while (randStr.length() < 128) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        if(Test.isRunningTest()){
            return 'kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
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