@IsTest
private class IdPortenTokenRefreshController_Test {
    @TestSetup
    static void makeData() {
        IdPortenCache__c cache = new IdPortenCache__c();
        cache.Name = 'QsSodfCDUpKRIYQb_fL2KUd-7UUBxEnQz7mcJxMX344';
        cache.UserId__c = UserInfo.getUserId();
        cache.ExpirationTime__c = DateTime.Now().addMinutes(5);
        insert cache;
    }

    @IsTest
    private static void redirect_getAuthorizationCodeUrl() {
        Test.startTest();
        IdPortenTokenRefreshController controller = new IdPortenTokenRefreshController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

        System.assertNotEquals(null, nextPage, 'Expect a redirect url');
    }

    @IsTest
    private static void redirect_handleCallback() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie codeVerifierCookie = new Cookie('codeverifier', 'codeverifier', null, -1, true);
        Cookie stateCookie = new Cookie('state', 'state', null, -1, true);
        Cookie nonceCookie = new Cookie('nonce', 'noncetest', null, -1, true);
        Cookie redirectUrlCookie = new Cookie('redirectUrl', '/', null, -1, true);
        Pagereference pageRef = Page.IdPortenTokenRefresh;
        pageRef.setCookies(new List<Cookie>{ codeVerifierCookie, stateCookie, nonceCookie, redirectUrlCookie });

        Test.startTest();

        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state', 'state');
        IdPortenTokenRefreshController controller = new IdPortenTokenRefreshController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        System.assertEquals(0, [SELECT COUNT() FROM Application_Log__c], 'Expect no errors');

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM IdPortenCache__c
                WHERE ExpirationTime__c > :DateTime.Now().addMinutes(20) AND UserId__c = :UserInfo.getUserId()
            ],
            'Expect Id Porten cache expiration time to be extended'
        );
    }

    @IsTest
    private static void redirect_handleCallback_whenCookiesIsNotSet() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        Cookie redirectUrlCookie = new Cookie('redirectUrl', '/', null, -1, true);
        Pagereference pageRef = Page.IdPortenTokenRefresh;
        pageRef.setCookies(new List<Cookie>{ redirectUrlCookie });

        Test.startTest();
        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state', 'state');
        IdPortenTokenRefreshController controller = new IdPortenTokenRefreshController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenTokenRefreshController'
            ORDER BY CreatedDate
        ];
        System.assertEquals(1, errorLogs.size(), 'Throw 1 error');
        System.assertEquals('Cookies er ikke satt', errorLogs[0].Log_Message__c);
    }

    @IsTest
    private static void redirect_handleCallback_whenStateNotMatching() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());

        //set cookies
        Cookie codeVerifierCookie = new Cookie('codeverifier', 'codeverifier', null, -1, true);
        Cookie stateCookie = new Cookie('state', 'state', null, -1, true);
        Cookie nonceCookie = new Cookie('nonce', 'noncetest', null, -1, true);
        Cookie redirectUrlCookie = new Cookie('redirectUrl', '/', null, -1, true);
        Pagereference pageRef = Page.IdPortenTokenRefresh;
        pageRef.setCookies(new List<Cookie>{ codeVerifierCookie, stateCookie, nonceCookie, redirectUrlCookie });

        Test.startTest();

        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('code', 'abc');
        pageRef.getParameters().put('state', 'anotherState');
        IdPortenTokenRefreshController controller = new IdPortenTokenRefreshController();
        String nextPage = controller.redirect().getUrl();
        Test.stopTest();

        System.assertEquals('/', nextPage, 'Expected to finish login flow');
        List<Application_Log__c> errorLogs = [
            SELECT Log_Message__c
            FROM Application_Log__c
            WHERE Source_Class__c = 'IdPortenTokenRefreshController'
        ];
        System.assertEquals(1, errorLogs.size(), 'Throw 1 error');
        System.assertEquals('State samsvarer ikke', errorLogs[0].Log_Message__c);
    }

    @IsTest
    private static void redirect_validateNotScratch() {
        Test.setMock(HttpCalloutMock.class, new TokenEndpointMock());
        Pagereference pageRef = Page.IdPortenTokenRefresh;

        Test.startTest();

        test.setCurrentPage(pageRef);
        pageRef.getParameters().put('redirectUrl', '/');
        IdPortenTokenRefreshController controller = new IdPortenTokenRefreshController();
        PageReference redirectPage = controller.validateAndRedirect();
        Test.stopTest();
        String nextPage = redirectPage.getUrl();
        
        Organization org = [SELECT IsSandbox, TrialExpirationDate FROM Organization];
        Boolean isScratchOrg = org?.IsSandbox && org?.TrialExpirationDate != null;
        if(isScratchOrg) {
            Assert.areEqual('/', nextPage, 'Expected to get redirectUrl');
        } else {
            Assert.isTrue(nextPage.startsWith('https://auth'), 'Expected to get auth URL outside scratch');
        }
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
