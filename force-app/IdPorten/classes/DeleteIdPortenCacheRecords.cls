public with sharing class DeleteIdPortenCacheRecords {
    public void deleteRecords() {
        runDelete(getIdPortenCacheRecords());
    }

    private List<IdPortenCache__c> getIdPortenCacheRecords() {
        DateTime timeToExpire = Datetime.now().addMinutes(-25);
        DateTime toOldToExpire = Datetime.now().addHours(-1); // Session is expired at this time, so no need to query and delete older session records.
        return [
            SELECT Id
            FROM IdPortenCache__c
            WHERE CreatedDate <= :timeToExpire AND CreatedDate > :toOldToExpire
            LIMIT 2000
        ];
    }

    @TestVisible
    private void runDelete(List<IdPortenCache__c> recordsToDelete) {
        if (recordsToDelete.isEmpty()) {
            return;
        }

        List<Id> recordIdsToDelete = new List<Id>();
        for (IdPortenCache__c recordToDelete : recordsToDelete) {
            recordIdsToDelete.add(recordToDelete.Id);
        }

        List<Database.DeleteResult> deleteResults = Database.delete(recordIdsToDelete);
        Database.emptyRecycleBin(recordIdsToDelete);
        LoggerUtility logger = new LoggerUtility('Logout');
        Integer successCount = 0;
        Integer failedCount = 0;
        for (Database.DeleteResult result : deleteResults) {
            if (result.isSuccess()) {
                successCount += 1;
            } else {
                failedCount += 1;
            }
        }
        if (successCount > 0) {
            logger.info('Deleted ' + successCount + ' Id Porten Caches.', null, CRM_ApplicationDomain.Domain.CRM);
        }
        if (failedCount > 0) {
            logger.critical(
                'Failed to delete ' +
                failedCount +
                ' Id Porten Caches:',
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
        }
        logger.publish();
    }
}
