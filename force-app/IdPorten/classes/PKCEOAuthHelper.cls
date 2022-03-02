public class PKCEOAuthHelper {

    public static void printDetails(){
        String code_verifier  = generateRandomString(34);
        Blob sha256           = Crypto.generateDigest('SHA-256', Blob.valueOf(code_verifier));
        String code_challenge = base64URLencode(sha256);
        
        System.debug('**** code_verifier **** \n  '+code_verifier);
        System.debug('**** code_challenge **** \n '+code_challenge);
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
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    }