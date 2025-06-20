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
        List<AuthSession> authSessionsToDelete = [
            SELECT Id
            FROM AuthSession
            WHERE
                UsersId = :userIds
                AND LoginType = 'Chatter Communities External User Third Party SSO'
        ];

        if (authSessionsToDelete.isEmpty()) {
            return;
        }

        List<Database.DeleteResult> deleteResults = Database.delete(
            authSessionsToDelete,
            false
        );

        handleDeleteResult(deleteResults);
    }

    @TestVisible
    private static void handleDeleteResult(
        List<Database.DeleteResult> deleteResults
    ) {
        LoggerUtility logger = new LoggerUtility(
            CRM_ApplicationDomain.Domain.PLATFORCE,
            'Logout'
        );
        for (Database.DeleteResult result : deleteResults) {
            if (!result.isSuccess()) {
                String errors = '';

                for (Database.Error error : result.getErrors()) {
                    errors += error.getMessage() + '\n';
                }

                logger.logMessage(
                    LoggerUtility.LogLevel.ERROR,
                    result.id,
                    null,
                    'Error deleting AuthSession for Experience User.',
                    errors,
                    null
                );
            }
        }
        logger.publish();
    }
}
