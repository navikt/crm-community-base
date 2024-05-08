@IsTest
private with sharing class DeleteIdPortenCacheScheduler_Test {
    @IsTest
    private static void reScheduleTest() {
        Test.startTest();
        DeleteIdPortenCacheScheduler.reSchedule();
        Test.stopTest();
    }

    @IsTest
    private static void reScheduleDoubleTest() {
        Test.startTest();
        System.schedule(
            'Delete Id Porten Cache Records - test',
            DeleteIdPortenCacheScheduler.getCronExpression(System.now().addDays(1)),
            new DeleteIdPortenCacheScheduler()
        );
        DeleteIdPortenCacheScheduler.reSchedule();
        Test.stopTest();
    }
}
