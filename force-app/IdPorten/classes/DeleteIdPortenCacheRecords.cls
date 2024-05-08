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

        Database.delete(recordIdsToDelete);
        Database.emptyRecycleBin(recordIdsToDelete);
    }
}
