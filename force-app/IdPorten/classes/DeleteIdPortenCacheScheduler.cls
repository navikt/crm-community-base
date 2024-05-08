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

    public void execute(SchedulableContext SC) {
        try {
            new DeleteIdPortenCacheRecords().deleteRecords();
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.CRM);
            logger.publishSynch();
        }
        DeleteIdPortenCacheScheduler.reSchedule(SC);
    }

    public static void reSchedule() {
        DeleteIdPortenCacheScheduler.reSchedule(null);
    }

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

    private static void reSchedule(SchedulableContext SC) {
        if (SC != null) {
            for (CronTrigger ct : DeleteIdPortenCacheScheduler.getActiveCronTriggers()) {
                if (SC.getTriggerId() != ct.Id) {
                    return;
                }
            }
        }

        DateTime cronJobTime = System.now().addMinutes(FIVE_MINUTES);

        String cronExpression = DeleteIdPortenCacheScheduler.getCronExpression(cronJobTime);
        String jobName = DeleteIdPortenCacheScheduler.getJobName(cronJobTime);
        System.schedule(jobName, cronExpression, new DeleteIdPortenCacheScheduler());
    }

    private static String getJobName(DateTime cronJobTime) {
        String jobName = JOB_NAME + ' - ' + cronJobTime.format();

        if (Test.isRunningTest()) {
            jobName += '- ' + (Integer) Math.floor(Math.random() * 10000);
        }

        return jobName;
    }

    public static void stopSchedule() {
        try {
            for (CronTrigger cronTrigger : DeleteIdPortenCacheScheduler.getActiveCronTriggers()) {
                System.abortJob(cronTrigger.Id);
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @TestVisible
    private static List<CronTrigger> getActiveCronTriggers() {
        return [
            SELECT Id
            FROM CronTrigger
            WHERE
                CronJobDetail.JobType = '7'
                AND CronJobDetail.Name LIKE :JOB_NAME + '%'
                AND State IN :DeleteIdPortenCacheScheduler.CRON_TRIGGER_IS_SCHEDULED_STATES
                AND CreatedDate = LAST_N_DAYS:2
        ];
    }
}
