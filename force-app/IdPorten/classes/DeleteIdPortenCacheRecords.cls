public with sharing class DeleteIdPortenCacheRecords {
    private LoggerUtility logger;

    public DeleteIdPortenCacheRecords() {
        logger = new LoggerUtility('Logout');
    }

    public void deleteRecords() {
        runDelete(getIdPortenCacheRecords());
    }

    @TestVisible
    private List<IdPortenCache__c> getIdPortenCacheRecords() {
        return [
            SELECT Id
            FROM IdPortenCache__c
            WHERE ExpirationTime__c <= :Datetime.now()
            WITH SECURITY_ENFORCED
            ORDER BY ExpirationTime__c ASC NULLS LAST
            LIMIT 2000
        ];
    }

    @TestVisible
    private void runDelete(List<IdPortenCache__c> recordsToDelete) {
        Integer successCount = 0;
        Integer failedCount = 0;
        List<Id> recordIdsToDelete = new List<Id>();
        List<Id> recordsToEmptyFromRecycleBin = new List<Id>();

        if (recordsToDelete == null || recordsToDelete.isEmpty()) {
            this.logger.info('No Id Porten Caches to delete.', null, CRM_ApplicationDomain.Domain.CRM);
            this.logger.publish();
            return;
        }

        for (IdPortenCache__c recordToDelete : recordsToDelete) {
            recordIdsToDelete.add(recordToDelete.Id);
        }

        List<Database.DeleteResult> deleteResults = Database.delete(recordIdsToDelete, false);

        recordsToEmptyFromRecycleBin = this.handleDeleteResult(deleteResults);

        if (recordsToEmptyFromRecycleBin.size() > 0) {
            List<Database.EmptyRecycleBinResult> emptyRecycleBinResults = Database.emptyRecycleBin(
                recordsToEmptyFromRecycleBin
            );
            this.handleEmptyRecycleBinResult(emptyRecycleBinResults);
        }

        this.logger.publish();
    }

    private void handleEmptyRecycleBinResult(List<Database.EmptyRecycleBinResult> emptyRecycleBinResults) {
        Integer successCount = 0;
        Integer failedCount = 0;

        for (Database.EmptyRecycleBinResult result : emptyRecycleBinResults) {
            if (result.isSuccess()) {
                successCount += 1;
            } else {
                failedCount += 1;
            }
        }

        if (successCount > 0) {
            this.logger.info(
                'Emptied ' +
                successCount +
                ' Id Porten Cache records from the recycle Bin.',
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
        }

        if (failedCount > 0) {
            this.logger.critical(
                'Failed to empty ' +
                failedCount +
                ' Id Porten Cache records from the recycle bin',
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
        }
    }

    private List<Id> handleDeleteResult(List<Database.DeleteResult> deleteResults) {
        List<Id> recordsToEmptyFromRecycleBin = new List<Id>();
        Integer successCount = 0;
        Integer failedCount = 0;

        for (Database.DeleteResult result : deleteResults) {
            if (result.isSuccess()) {
                successCount += 1;
                recordsToEmptyFromRecycleBin.add(result.getId());
            } else {
                failedCount += 1;
            }
        }

        if (successCount > 0) {
            this.logger.info('Deleted ' + successCount + ' Id Porten Caches.', null, CRM_ApplicationDomain.Domain.CRM);
        }
        if (failedCount > 0) {
            this.logger.critical(
                'Failed to delete ' +
                failedCount +
                ' Id Porten Caches:',
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
        }
        return recordsToEmptyFromRecycleBin;
    }
}
