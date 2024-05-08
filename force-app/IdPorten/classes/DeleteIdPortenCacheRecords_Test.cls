@IsTest
private with sharing class DeleteIdPortenCacheRecords_Test {
    @IsTest
    private static void runDelete_Success() {
        IdPortenCache__c testRecord = new IdPortenCache__c(Name = 'Test');
        Id testId = testRecord.Id;
        insert testRecord;

        Test.startTest();
        new DeleteIdPortenCacheRecords().runDelete(new List<IdPortenCache__c>{ testRecord });
        Test.stopTest();

        List<IdPortenCache__c> result = [SELECT Id FROM IdPortenCache__c WHERE Id = :testId ALL ROWS];

        Assert.areEqual(0, result.size(), 'Expected record to be deleted from recycle bin');
    }

    @IsTest
    private static void testDeleteRecords_noRecords() {
        Test.startTest();
        new DeleteIdPortenCacheRecords().deleteRecords();
        Test.stopTest();
    }
}
