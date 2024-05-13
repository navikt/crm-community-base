/**
 * @description Class for deleting expired IdPortenCache__c records. Deleted records are also removed from the Recycle Bin.
 * Example code: `new DeleteIdPortenCacheRecords.deleteRecords();`
 *
 * The job will delete a maximum of 2000 records for each run;
 * The results (successes and errors) are logged under the category 'Logout'
 *
 * NOTE: Records in the recycle bin might still be visible in a query all:
 * `Each Salesforce instance has a 'sweeper' thread that goes through the database(s) and removes records from tables that are in a deleted status. There is no first deleted first removed to this process. So records can remain on the table long after you have deleted and removed them from the recycle bin.`
 * @author Tor Håkon Sigurdsen
 * @since 2024-05-08
 */
public with sharing class DeleteIdPortenCacheRecords {
    @TestVisible
    private LoggerUtility logger;

    /**
     * @description constructor
     */
    public DeleteIdPortenCacheRecords() {
        logger = new LoggerUtility('Logout');
    }

    /**
     * @description Delete IdPortenCache__c records
     */
    public void deleteRecords() {
        runDelete(getIdPortenCacheRecords());
        this.logger.publish();
    }

    /**
     * @description Query all expired IdPortenCache__c records ordered acending by ExpirationTime__c (limit 2000)
     * @return `List<IdPortenCache__c>`
     */
    @TestVisible
    private List<IdPortenCache__c> getIdPortenCacheRecords() {
        DateTime startDate = DateTime.newInstance(2024, 5, 9);
        return [
            SELECT Id
            FROM IdPortenCache__c
            WHERE CreatedDate > :startDate AND ExpirationTime__c <= :Datetime.now()
            WITH SECURITY_ENFORCED
            ORDER BY ExpirationTime__c ASC NULLS LAST
            LIMIT 2000
        ];
    }

    /**
     * @description Delete all supplied records and remove them from the recycle bin
     * @param recordsToDelete `List<IdPortenCache__c>`
     */
    @TestVisible
    private void runDelete(List<IdPortenCache__c> recordsToDelete) {
        List<Id> recordIdsToDelete = new List<Id>();
        List<Id> recordsToEmptyFromRecycleBin = new List<Id>();

        // If no records to delete return
        if (recordsToDelete == null || recordsToDelete.isEmpty()) {
            this.logger.info('No Id Porten Caches to delete.', null, CRM_ApplicationDomain.Domain.CRM);
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
    }

    /**
     * @description Iterate over a list of `Database.EmptyRecycleBinResult` and count successes and failures and log the result.
     *
     * @param emptyRecycleBinResults `List<Database.EmptyRecycleBinResult>`
     */
    @TestVisible
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

    /**
     * @description Iterate over a list of `Database.DeleteResult` and count successes and failures and log the result.
     * Return a list of the Id's of all successfully deleted records
     *
     * @param deleteResults `List<Database.DeleteResult>`
     * @return recordsToEmptyFromRecycleBin `List<Id>`
     */
    @TestVisible
    private List<Id> handleDeleteResult(List<Database.DeleteResult> deleteResults) {
        List<Id> recordsToEmptyFromRecycleBin = new List<Id>();
        Integer successCount = 0;
        Integer failedCount = 0;

        for (Database.DeleteResult result : deleteResults) {
            if (result.isSuccess()) {
                successCount += 1;

                //Add to list in order to remove it from the recycle bin
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
