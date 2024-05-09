global class IdPortenCacheDeleteHandler extends MyTriggers {
    global override void onBeforeDelete() {
        Set<Id> userIds = new Set<Id>();
        for (IdPortenCache__c cache : (List<IdPortenCache__c>) records) {
            if (cache.CreatedDate > DateTime.Now().addDays(-1)) {
                userIds.add(cache.UserId__c);
            }
        }

        if (userIds.size() > 0) {
            IdPortenCacheDeleteHandler.performDelete(userIds);
        }
    }

    @future
    public static void performDelete(Set<Id> userIds) {
        LoggerUtility logger = new LoggerUtility('Logout');
        Integer successCount = 0;
        Integer failedCount = 0;

        try {
            List<AuthSession> authSessionsToDelete = [
                SELECT Id
                FROM AuthSession
                WHERE UsersId = :userIds AND LoginType = 'Chatter Communities External User Third Party SSO'
            ];

            if (authSessionsToDelete.isEmpty()) {
                logger.info('No auth sessions to delete found', null, CRM_ApplicationDomain.Domain.CRM);
                logger.publish();
                return;
            }

            List<Database.DeleteResult> deleteResults = Database.delete(authSessionsToDelete, false);

            for (Database.DeleteResult result : deleteResults) {
                if (result.isSuccess()) {
                    successCount += 1;
                } else {
                    failedCount += 1;
                }
            }

            if (successCount > 0) {
                logger.info('Deleted ' + successCount + ' AuthSession.', null, CRM_ApplicationDomain.Domain.CRM);
            }
            if (failedCount > 0) {
                logger.critical(
                    'Failed to delete ' +
                    failedCount +
                    ' AuthSession:',
                    null,
                    CRM_ApplicationDomain.Domain.CRM
                );
            }

            delete [
                SELECT Id
                FROM AuthSession
                WHERE UsersId = :userIds AND LoginType = 'Chatter Communities External User Third Party SSO'
            ];
        } catch (Exception e) {
            logger.critical(
                'Could not delete AuthSession while deleting Id Porten cache. + \n' +
                userIds +
                '\n' +
                e.getMessage(),
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
        }
        logger.publish();
    }
}
