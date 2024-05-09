@IsTest
private with sharing class DeleteIdPortenCacheRecords_Test {
    @IsTest
    private static void getIdPortenCacheRecordsNoRecords() {
        List<IdPortenCache__c> result;
        Test.startTest();
        result = new DeleteIdPortenCacheRecords().getIdPortenCacheRecords();
        Test.stopTest();

        Assert.isNotNull(result, 'Did not expect null, but an empty list');
        Assert.isTrue(result.isEmpty(), 'Expected that no record has been selected');
    }

    @IsTest
    private static void getIdPortenCacheRecordsMultipleRecords() {
        List<IdPortenCache__c> cacheList = new List<IdPortenCache__c>();
        cacheList.add(new IdPortenCache__c(Name = 'Test0', ExpirationTime__c = Datetime.now()));
        cacheList.add(new IdPortenCache__c(Name = 'Test1', ExpirationTime__c = Datetime.now().addMinutes(25)));
        cacheList.add(new IdPortenCache__c(Name = 'Test2', ExpirationTime__c = Datetime.now().addMinutes(-5)));
        cacheList.add(new IdPortenCache__c(Name = 'Test3', ExpirationTime__c = null));
        insert cacheList;

        List<IdPortenCache__c> results;
        Test.startTest();
        results = new DeleteIdPortenCacheRecords().getIdPortenCacheRecords();
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Expected two records selected');
        Assert.areEqual(
            cacheList[2].Id,
            results[0].Id,
            'Expected the record with the oldest ExpirationTime__c to be first'
        );
        Assert.areEqual(
            cacheList[0].Id,
            results[1].Id,
            'Expected the record with the newest ExpirationTime__c to be last'
        );
    }

    @IsTest
    private static void runDeleteSuccess() {
        IdPortenCache__c testRecord = new IdPortenCache__c(Name = 'Test', ExpirationTime__c = Datetime.now());
        insert testRecord;

        Test.startTest();
        new DeleteIdPortenCacheRecords().runDelete(new List<IdPortenCache__c>{ testRecord });
        Test.stopTest();

        List<IdPortenCache__c> result = [SELECT Id, isDeleted FROM IdPortenCache__c WHERE IsDeleted = TRUE ALL ROWS];

        Assert.areEqual(1, result.size(), 'Expected record to be deleted');
    }

    @IsTest
    private static void runDeleteNoRecords() {
        Test.startTest();
        new DeleteIdPortenCacheRecords().runDelete(new List<IdPortenCache__c>());
        Test.stopTest();

        List<Application_Log__c> logs = [SELECT Id, Log_Level__c FROM Application_Log__c WHERE Category__c = 'Logout'];

        Assert.areEqual(1, logs.size(), 'Expected one log record');
        Assert.areEqual('Info', logs[0].Log_Level__c, 'Expected that we had an info record');
    }

    @IsTest
    private static void runDeleteNull() {
        Test.startTest();
        new DeleteIdPortenCacheRecords().runDelete(null);
        Test.stopTest();

        List<Application_Log__c> logs = [SELECT Id, Log_Level__c FROM Application_Log__c WHERE Category__c = 'Logout'];

        Assert.areEqual(1, logs.size(), 'Expected one log record');
        Assert.areEqual('Info', logs[0].Log_Level__c, 'Expected that we had an info record');
    }
}
