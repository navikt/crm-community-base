@IsTest
public class CodeVerifierPostMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setBody('{"codeVerifier":"abc","nonce":"non","state":"def"}'); 
        response.setStatusCode(200);
        return response; 
    }
}