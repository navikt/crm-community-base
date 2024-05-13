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

    @IsTest
    private static void stopScheduleTest() {
        DateTime scheduledTime = System.now().addMinutes(5);
        Integer jobsBeforeStopIsRun = 0;
        Integer jobsAfterStopIsRun = 0;
        System.schedule(
            DeleteIdPortenCacheScheduler.getJobName(scheduledTime),
            DeleteIdPortenCacheScheduler.getCronExpression(scheduledTime),
            new DeleteIdPortenCacheScheduler()
        );

        Test.startTest();
        jobsBeforeStopIsRun = DeleteIdPortenCacheScheduler.getActiveCronTriggers().size();
        DeleteIdPortenCacheScheduler.stopSchedule();
        jobsAfterStopIsRun = DeleteIdPortenCacheScheduler.getActiveCronTriggers().size();
        Test.stopTest();

        Assert.areEqual(1, jobsBeforeStopIsRun, 'Expected nmb of jobs existing before the test starts to be zero');
        Assert.areEqual(0, jobsAfterStopIsRun, 'Expected nmb of jobs existing after the test stops to be zero');
    }

    @IsTest
    private static void stopScheduleNoScheduledJobs() {
        Integer jobsBeforeStopIsRun = 0;
        Integer jobsAfterStopIsRun = 0;

        Test.startTest();
        jobsBeforeStopIsRun = DeleteIdPortenCacheScheduler.getActiveCronTriggers().size();
        DeleteIdPortenCacheScheduler.stopSchedule();
        jobsAfterStopIsRun = DeleteIdPortenCacheScheduler.getActiveCronTriggers().size();
        Test.stopTest();

        Assert.areEqual(0, jobsBeforeStopIsRun, 'Expected nmb of jobs existing before the test starts to be zero');
        Assert.areEqual(0, jobsAfterStopIsRun, 'Expected nmb of jobs existing after the test stops to be zero');
    }
}
