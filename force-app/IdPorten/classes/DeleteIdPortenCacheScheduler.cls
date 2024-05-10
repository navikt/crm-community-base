/**
 * @description Scheduled class for deleting `IdPortenCache__c` records.
 * This class mainly hold logic for handling the scheduling, the delete logic are found in `DeleteIdPortenCacheRecords`
 *
 *  To schedule the class either run `DeleteIdPortenCacheScheduler.reSchedule();` or use the standard `System.schedule` method.
 *  To abort the scheduled job run `DeleteIdPortenCacheScheduler.stopSchedule();`
 *
 * @author Tor Håkon Sigurdsen
 * @since 2024-05-08
 */
public with sharing class DeleteIdPortenCacheScheduler implements Schedulable {
    private static final String JOB_NAME = 'Delete Id Porten Cache Records';
    private static final Integer FIVE_MINUTES = 5;
    private static final Set<String> CRON_TRIGGER_IS_SCHEDULED_STATES = new Set<String>{
        'WAITING',
        'ACQUIRED',
        'EXECUTING',
        'PAUSED',
        'BLOCKED',
        'PAUSED_BLOCKED'
    };

    /**
     * @description calls on `DeleteIdPortenCacheRecords` and then reschedules itself.
     * @param sc `SchedulableContext`
     */
    public void execute(SchedulableContext sc) {
        try {
            new DeleteIdPortenCacheRecords().deleteRecords();
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility('Logout');
            logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }
        DeleteIdPortenCacheScheduler.reSchedule(sc);
    }

    /**
     * @description Schedule a run for deleting Id Porten Cache records
     * Will not reschedule if the job is already scheduled or running.
     * @return jobId `String`
     */
    public static String reSchedule() {
        return DeleteIdPortenCacheScheduler.reSchedule(null);
    }

    /**
     * @description generate a cron expression based on the supplied `DateTime`
     * @param dt `DateTime`
     * @return cronExpression `String`
     */
    @TestVisible
    private static String getCronExpression(DateTime dt) {
        String cronExpression =
            '' +
            dt.second() +
            ' ' +
            dt.minute() +
            ' ' +
            dt.hour() +
            ' ' +
            dt.day() +
            ' ' +
            dt.month() +
            ' ? ' +
            dt.year();

        return cronExpression;
    }

    /**
     * @description Method for rescheduling the job
     * The job will not reschedule itself if a scheduled job already exists.
     * If called from a running scheduled job, supply the `SchedulableContext` in order to ignore the running job.
     *
     * @param sc `SchedulableContext`
     * @return jobId `String`
     */
    private static String reSchedule(SchedulableContext sc) {
        for (CronTrigger ct : DeleteIdPortenCacheScheduler.getActiveCronTriggers()) {
            if (sc == null || SC.getTriggerId() != ct.Id) {
                return '';
            }
        }

        DateTime cronJobTime = System.now().addMinutes(FIVE_MINUTES);
        String cronExpression = DeleteIdPortenCacheScheduler.getCronExpression(cronJobTime);
        String jobName = DeleteIdPortenCacheScheduler.getJobName(cronJobTime);

        return System.schedule(jobName, cronExpression, new DeleteIdPortenCacheScheduler());
    }

    /**
     * @description Create a job name based on the scheduled run time
     * @param cronJobTime `DateTime`
     * @return jobName `String`
     */
    @TestVisible
    private static String getJobName(DateTime cronJobTime) {
        String jobName = JOB_NAME;

        //In order to avoid duplicate job names causing issues in test we add four diget random number.
        if (Test.isRunningTest()) {
            jobName += ' TEST - ' + (Integer) Math.floor(Math.random() * 10000);
        }

        jobName += ' - ' + cronJobTime.format();
        return jobName;
    }

    /**
     * @description Stop all scheduled jobs
     */
    public static void stopSchedule() {
        try {
            for (CronTrigger cronTrigger : DeleteIdPortenCacheScheduler.getActiveCronTriggers()) {
                System.abortJob(cronTrigger.Id);
            }
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility('Logout');
            logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }
    }

    /**
     * @description Get the Id of all the scheduled `CronTrigger` records with a name starting with the `JOB_NAME` constant
     * @return `List<CronTrigger>`
     */
    @TestVisible
    private static List<CronTrigger> getActiveCronTriggers() {
        return [
            SELECT Id, CronJobDetail.Name, State
            FROM CronTrigger
            WHERE
                CronJobDetail.JobType = '7'
                AND CronJobDetail.Name LIKE :JOB_NAME + '%'
                AND State IN :DeleteIdPortenCacheScheduler.CRON_TRIGGER_IS_SCHEDULED_STATES
                AND CreatedDate = LAST_N_DAYS:2
            WITH SECURITY_ENFORCED
        ];
    }
}
