@IsTest
private class IdPortenTokenRefreshController_Test {
    @IsTest
    private static void testGetNewRefreshToken() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie refreshTokenCookie = new Cookie('refreshToken', 'refresh', null, -1, true);
        Pagereference pageRef = Page.IdPortenTokenRefresh;
        pageRef.setCookies(new List<Cookie>{ refreshTokenCookie });

        Test.startTest();

        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('redirectUrl', 'https://www.test.com');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenSidController'
        ];
        System.assertEquals(0, errorLogs.size(), 'Expect no errors');

        System.assertEquals('https://www.test.com', nextPage, 'Expected to redirect to redirect url');
    }

    @IsTest
    private static void testGetNewRefreshToken_refreshTokenCookieNotFound() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        Pagereference pageRef = Page.IdPortenTokenRefresh;

        Test.startTest();

        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('redirectUrl', 'https://www.test.com');
        IdPortenSidController controller = new IdPortenSidController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenSidController'
        ];
        System.assertEquals(1, errorLogs.size(), 'Throw 1 error');
        System.assertEquals('https://www.test.com', nextPage, 'Expected to redirect to redirect url');
    }

    public class TokenEndpointMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            String idToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdF9oYXNoIjoiSGs1TDE4WVVDTVZHbjFLNFBpckY2QSIsInN1YiI6Ii10c01LdWxFNUZHQUU1WkhRRUVlLWNsT2ZqS1VheGpYVmNXc2RsaHFBRWM9IiwiYW1yIjpbIkJhbmtJRCJdLCJpc3MiOiJodHRwczovL29pZGMtdmVyMi5kaWZpLm5vL2lkcG9ydGVuLW9pZGMtcHJvdmlkZXIvIiwicGlkIjoiMTYxMjAxMDExODEiLCJsb2NhbGUiOiJuYiIsInNpZCI6IlFzU29kZkNEVXBLUklZUWJfZkwyS1VkLTdVVUJ4RW5RejdtY0p4TVgzNDQiLCJhdWQiOiJhMDY5NjYxMi1lZmM0LTQ2ZTktYTdjOS1iZmY2NTZlNTU0YzIiLCJhY3IiOiJMZXZlbDQiLCJhdXRoX3RpbWUiOjE2NDYyMjU4MjIsImV4cCI6MTY0NjIyNzE2MywiaWF0IjoxNjQ2MjI3MDQzLCJub25jZSI6Im5vbmNldGVzdCIsImp0aSI6Ik41Uk1KQmZhYnlOTklkZUFpcmMxZUJmMUZYX1VQNHhjazVZUEoydWhQQncifQ.5-MEpzms1cH97aAFVM2bNATADrdSiWxt1s_ZtiOgJ1w';
            res.setBody('{"access_token":"access","refresh_token":"refresh", "id_token":"' + idToken + '"}');
            res.setStatusCode(200);
            return res;
        }
    }
}
