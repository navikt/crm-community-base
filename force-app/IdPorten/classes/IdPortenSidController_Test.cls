@IsTest
private class IdPortenSidController_Test {
    
    @IsTest
    private static void redirect_getAuthorizationCodeUrl() {
        Test.startTest();
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

       
        System.assertNotEquals(
            null,
            nextPage,
            'Expect a redirect url'
        );
    }

    @IsTest
    private static void redirect_handleCallback() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie codeVerifierCookie = new Cookie('codeverifier','codeverifier',null,-1,true);
        Cookie stateCookie = new Cookie('state','state',null,-1,true);
        Cookie nonceCookie = new Cookie('nonce','noncetest',null,-1,true);
        Cookie retUrlCookie = new Cookie('retUrl','/',null,-1,true);
        Pagereference pageRef = Page.IdPortenSid;
	    pageRef.setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie, retUrlCookie });
        
        Test.startTest();
       
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state','state');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();
      
        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        System.assertEquals(0,[SELECT COUNT() FROM Application_Log__c], 'Expect no errors');

    }

    @IsTest
    private static void redirect_handleCallback_whenCookiesIsNotSet() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());
        
        Test.startTest();
        Pagereference pageRef = Page.IdPortenSid;
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state','state');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();
        
        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        List<Application_Log__c> errorLogs=[SELECT 	Log_Message__c FROM Application_Log__c WHERE Source_Class__c='IdPortenSidController' ORDER BY CreatedDate];
        System.assertEquals(2,errorLogs.size(), 'Throw 2 errors');
        System.assertEquals('Cookies er ikke satt', errorLogs[0].Log_Message__c);

    }

    @IsTest
    private static void redirect_handleCallback_whenStateNotMatching() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie codeVerifierCookie = new Cookie('codeverifier','codeverifier',null,-1,true);
        Cookie stateCookie = new Cookie('state','state',null,-1,true);
        Cookie nonceCookie = new Cookie('nonce','noncetest',null,-1,true);
        Cookie retUrlCookie = new Cookie('retUrl','/',null,-1,true);
        Pagereference pageRef = Page.IdPortenSid;
	    pageRef.setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie, retUrlCookie });
        
        Test.startTest();
       
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state','anotherState');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();
        
        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        List<Application_Log__c> errorLogs=[SELECT 	Log_Message__c FROM Application_Log__c WHERE Source_Class__c='IdPortenSidController'];
        System.assertEquals(1,errorLogs.size(), 'Throw 1 error');
        System.assertEquals('State samsvarer ikke', errorLogs[0].Log_Message__c);

    }

    @IsTest
    private static void redirect_handleCallback_whenNonceIsBlank() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie codeVerifierCookie = new Cookie('codeverifier','codeverifier',null,-1,true);
        Cookie stateCookie = new Cookie('state','state',null,-1,true);
        Cookie nonceCookie = new Cookie('nonce',null,null,-1,true);
        Cookie retUrlCookie = new Cookie('retUrl','/',null,-1,true);
        Pagereference pageRef = Page.IdPortenSid;
	    pageRef.setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie, retUrlCookie });
        
        Test.startTest();
       
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state','state');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();
        
        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        List<Application_Log__c> errorLogs=[SELECT 	Log_Message__c FROM Application_Log__c WHERE Source_Class__c='IdPortenSidController'];
        System.assertEquals(1,errorLogs.size(), 'Throw 1 error');
        System.assertEquals('Nonce er blank', errorLogs[0].Log_Message__c);

    }

    @IsTest
    private static void redirect_handleCallback_whenCodeVeriferIsBlank() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie codeVerifierCookie = new Cookie('codeverifier',null,null,-1,true);
        Cookie stateCookie = new Cookie('state','state',null,-1,true);
        Cookie nonceCookie = new Cookie('nonce','noncetest',null,-1,true);
        Cookie retUrlCookie = new Cookie('retUrl','/',null,-1,true);
        Pagereference pageRef = Page.IdPortenSid;
	    pageRef.setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie, retUrlCookie });
        
        Test.startTest();
       
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state','state');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();
        
        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        List<Application_Log__c> errorLogs=[SELECT 	Log_Message__c FROM Application_Log__c WHERE Source_Class__c='IdPortenSidController'];
        System.assertEquals(1,errorLogs.size(), 'Throw 1 error');
        System.assertEquals('Code verifier er blank', errorLogs[0].Log_Message__c);

    }

    public class TokenEndpointMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            String idToken='eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdF9oYXNoIjoiSGs1TDE4WVVDTVZHbjFLNFBpckY2QSIsInN1YiI6Ii10c01LdWxFNUZHQUU1WkhRRUVlLWNsT2ZqS1VheGpYVmNXc2RsaHFBRWM9IiwiYW1yIjpbIkJhbmtJRCJdLCJpc3MiOiJodHRwczovL29pZGMtdmVyMi5kaWZpLm5vL2lkcG9ydGVuLW9pZGMtcHJvdmlkZXIvIiwicGlkIjoiMTYxMjAxMDExODEiLCJsb2NhbGUiOiJuYiIsInNpZCI6IlFzU29kZkNEVXBLUklZUWJfZkwyS1VkLTdVVUJ4RW5RejdtY0p4TVgzNDQiLCJhdWQiOiJhMDY5NjYxMi1lZmM0LTQ2ZTktYTdjOS1iZmY2NTZlNTU0YzIiLCJhY3IiOiJMZXZlbDQiLCJhdXRoX3RpbWUiOjE2NDYyMjU4MjIsImV4cCI6MTY0NjIyNzE2MywiaWF0IjoxNjQ2MjI3MDQzLCJub25jZSI6Im5vbmNldGVzdCIsImp0aSI6Ik41Uk1KQmZhYnlOTklkZUFpcmMxZUJmMUZYX1VQNHhjazVZUEoydWhQQncifQ.5-MEpzms1cH97aAFVM2bNATADrdSiWxt1s_ZtiOgJ1w';
            res.setBody('{"access_token":"access","refresh_token":"refresh", "id_token":"' + idToken + '"}'); 
            res.setStatusCode(200);
            return res; 
        }
    }
}
