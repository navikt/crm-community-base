global class IdPortenCacheDeleteHandler extends MyTriggers {
    global override void onBeforeDelete() {
        Set<Id> userIds = new Set<Id>();
        for (IdPortenCache__c cache : (List<IdPortenCache__c>) records) {
            userIds.add(cache.UserId__c);
        }

        try {
            delete [
                SELECT Id
                FROM AuthSession
                WHERE UsersId = :userIds AND LoginType = 'Chatter Communities External User Third Party SSO'
            ];
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility('Logout');
            logger.critical(
                'Could not delete AuthSession while deleting Id Porten cache. + \n' +
                userIds +
                '\n' +
                e.getMessage(),
                null,
                CRM_ApplicationDomain.Domain.CRM
            );
            logger.publish();
        }
    }
}
