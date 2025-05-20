@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest(IsParallel=true)
private class IdPortenLogoutRestService_Test {
    @TestSetup
    static void makeData() {
        IdPortenCache__c cache = new IdPortenCache__c();
        cache.Name = 'sid';
        cache.UserId__c = '0051j000009na8sAAA'; // NOPMD - This is a test Id
        insert cache;
    }

    @IsTest
    private static void testLogoutBySessionIdWhenSidInCache() {
        System.Test.startTest();
        IdPortenLogoutRestService.logoutBySessionId('sid');
        System.Test.stopTest();

        System.Assert.areEqual(
            1,
            [SELECT COUNT() FROM IdPortenCache__c WHERE Name = 'sid'],
            'Cache is found'
        );
    }

    @IsTest
    private static void testLogoutBySessionIdWhenSidDoNotExistInCache() {
        System.Test.startTest();
        IdPortenLogoutRestService.logoutBySessionId('sid2');
        System.Test.stopTest();

        System.Assert.areEqual(
            1,
            [SELECT COUNT() FROM IdPortenCache__c WHERE Name = 'sid'],
            'Cache is not found and not deleted'
        );
    }

    @IsTest
    private static void getUserIdFromSessionIdWithCache() {
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();
        System.Test.startTest();
        String userId = service.getUserIdFromSessionId('sid');
        System.Test.stopTest();
        System.Assert.areEqual(
            '0051j000009na8sAAA',
            userId,
            'Expected userId when cache found'
        ); // NOPMD - This is a test Id
    }

    @IsTest
    private static void getUserIdFromSessionIdNoCache() {
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();
        System.Test.startTest();
        String userId = service.getUserIdFromSessionId('sid2');
        System.Test.stopTest();
        System.Assert.areEqual(
            null,
            userId,
            'Expected null when no cache found'
        );
    }

    @IsTest
    private static void getAuthSessionsForUserWithSessions() {
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();
        System.Test.startTest();
        List<AuthSession> sessions = service.getAuthSessionsForUser(
            '0051j000009na8sAAA'
        ); // NOPMD - This is a test Id
        System.Test.stopTest();
        System.Assert.areEqual(0, sessions.size(), 'Expected no session found'); //We cannot create AuthSession in test context so we can only see if the query will return empty
    }

    @IsTest
    private static void getAuthSessionsForUserWithNull() {
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();
        System.Test.startTest();
        List<AuthSession> sessions = service.getAuthSessionsForUser(null);
        System.Test.stopTest();
        System.Assert.areEqual(
            0,
            sessions.size(),
            'Expected no sessions found'
        );
    }

    @IsTest
    private static void deleteAuthSessionWithSessions() {
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();
        List<AuthSession> sessions = (List<AuthSession>) JSON.deserialize(
            '[{ "Id": "0AkKB00002Q8Atz0AF" }]',
            List<AuthSession>.class
        );
        System.Test.startTest();
        List<Database.DeleteResult> deleteResults = service.deleteAuthSession(
            sessions
        );
        System.Test.stopTest();
        System.Assert.areEqual(
            1,
            deleteResults.size(),
            'Expected one delete result'
        );
    }

    @IsTest
    private static void deleteAuthSessionWithNoSessions() {
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();
        System.Test.startTest();
        List<Database.DeleteResult> deleteResults = service.deleteAuthSession(
            new List<AuthSession>()
        );
        System.Test.stopTest();
        System.Assert.areEqual(
            0,
            deleteResults.size(),
            'Expected no delete results'
        );
    }

    @IsTest
    private static void testHandleDeleteResult() {
        List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();

        deleteResults.add(
            (Database.DeleteResult) JSON.deserialize(
                '{"success":false,"id":"0013000000abcdf","errors":[{"message":"Error1","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","fields":[]}]}',
                Database.DeleteResult.class
            )
        );
        deleteResults.add(
            (Database.DeleteResult) JSON.deserialize(
                '{"success":true,"id":"0013000000abcdg","errors":[]}',
                Database.DeleteResult.class
            )
        );
        deleteResults.add(
            (Database.DeleteResult) JSON.deserialize(
                '{"success":false,"id":"0013000000abcde","errors":[{"message":"Error3","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","fields":[]}]}',
                Database.DeleteResult.class
            )
        );
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();

        Test.startTest();
        service.handleDeleteResult(deleteResults);
        service.logger.publish();
        Test.stopTest();

        List<Application_Log__c> logs = [
            SELECT Id
            FROM Application_Log__c
            WHERE
                Category__c = 'IdPorten'
                AND Application_Domain__c = :CRM_ApplicationDomain.Domain.PLATFORCE.name()
        ];
        System.Assert.areEqual(2, logs.size(), 'Expected two log entries');
    }

    @IsTest
    private static void testHandleEmptyDeleteResult() {
        List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
        IdPortenLogoutRestService service = new IdPortenLogoutRestService();

        System.Test.startTest();
        service.handleDeleteResult(deleteResults);
        service.logger.publish();
        System.Test.stopTest();

        List<Application_Log__c> logs = [
            SELECT Id
            FROM Application_Log__c
            WHERE
                Category__c = 'IdPorten'
                AND Application_Domain__c = :CRM_ApplicationDomain.Domain.PLATFORCE.name()
        ];
        System.Assert.areEqual(0, logs.size(), 'Expected no log entries');
    }

    @IsTest
    private static void testException() {
        IdPortenCache__c cache = new IdPortenCache__c();
        cache.Name = 'sid3';
        cache.UserId__c = 'a'; // NOPMD - This is a test Id
        insert cache;

        System.Test.startTest();
        IdPortenLogoutRestService.logoutBySessionId('sid3');
        System.Test.stopTest();

        List<Application_Log__c> logs = [
            SELECT Id
            FROM Application_Log__c
            WHERE
                Category__c = 'IdPorten'
                AND Application_Domain__c = :CRM_ApplicationDomain.Domain.PLATFORCE.name()
        ];
        System.Assert.areEqual(1, logs.size(), 'Expected one log entry');
    }
}
