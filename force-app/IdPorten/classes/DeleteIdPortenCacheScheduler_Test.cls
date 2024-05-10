@IsTest
private with sharing class DeleteIdPortenCacheScheduler_Test {
    @IsTest
    private static void reScheduleTest() {
        String result;

        Test.startTest();
        result = DeleteIdPortenCacheScheduler.reSchedule();
        Test.stopTest();

        Assert.isTrue(
            String.isNotEmpty(result),
            'Expect that the job was scheduled and that we got a job id in response'
        );
    }

    @IsTest
    private static void reScheduleDoubleTest() {
        DateTime shcheduledTime = System.now().addMinutes(5);

        String result;

        Test.startTest();
        System.schedule(
            DeleteIdPortenCacheScheduler.getJobName(shcheduledTime),
            DeleteIdPortenCacheScheduler.getCronExpression(shcheduledTime),
            new DeleteIdPortenCacheScheduler()
        );
        result = DeleteIdPortenCacheScheduler.reSchedule();
        Test.stopTest();

        Assert.isTrue(String.isEmpty(result), 'Did not expect that the job was scheduled');
    }
}
