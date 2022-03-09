@IsTest
public class GetCodeVerifierMock implements HttpCalloutMock { 
    public HTTPResponse respond(HTTPRequest request) {
        String codeVerifier='kVrLZpcSnucojj-YzCjsMTg-bbyVJffWBLu5RuyPx~gh5l-PX6gL.PNiKxAMIjCaNpJCYS88m8KdX2OuVB2eA1I.w-~ZHNSe9O9XklFX_IH_dDbG~mdHxsswvSA5XtZD';
        String nonce='anw.HT3EPhTDA3j9GAg77ZLEupFB915wEdW2vyyqRgkFFbC11DQAIgQ6jG03kLwIiPY_TFY47h3M2SWFG0jDtyJb4suN8OQffFLqGONqlEhyv2hgLV7r7EfF-LpgSH~a';
      
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setStatusCode(200);
        response.setBody('{"codeVerifier":"' + codeVerifier + '","nonce":"' + nonce +'"}');
        return response; 
    }
}