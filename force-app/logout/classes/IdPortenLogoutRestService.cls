/**
 * @description REST service for logging out users from IdPorten
 *
 */
@RestResource(urlMapping='/idporten/logout/*')
global without sharing class IdPortenLogoutRestService {
    @TestVisible
    private LoggerUtility logger;

    private final static String LOGIN_TYPE = 'Chatter Communities External User Third Party SSO';

    /**
     * @description Logs out a user by deleting their AuthSession using their session ID from IdPorten.
     *
     * @param sid Session Id
     */
    @HttpPost
    global static void logoutBySessionId(String sid) {
        new IdPortenLogoutRestService().findAndRemoveAuthSession(sid);
    }

    /**
     * @description Constructor
     */
    public IdPortenLogoutRestService() {
        logger = new LoggerUtility(
            CRM_ApplicationDomain.Domain.PLATFORCE,
            'IdPorten'
        );
    }

    @TestVisible
    private void findAndRemoveAuthSession(String sid) {
        try {
            String userId = this.getUserIdFromSessionId(sid);
            List<AuthSession> sessions = this.getAuthSessionsForUser(userId);
            List<Database.DeleteResult> deleteResults = this.deleteAuthSession(
                sessions
            );
            this.handleDeleteResult(deleteResults);
        } catch (Exception e) {
            logger.critical(
                'Could not delete AuthSession while logging out user. \n' +
                e.getMessage(),
                null,
                CRM_ApplicationDomain.Domain.PLATFORCE
            );
        }
        logger.publish();
    }

    @TestVisible
    private String getUserIdFromSessionId(String sid) {
        List<IdPortenCache__c> cache = [
            SELECT UserId__c
            FROM IdPortenCache__c
            WHERE Name = :sid
        ];

        if (cache.size() > 0) {
            return cache[0].UserId__c;
        } else {
            return null;
        }
    }

    @TestVisible
    private List<AuthSession> getAuthSessionsForUser(Id userId) {
        if (String.isBlank(userId)) {
            return new List<AuthSession>();
        }
        return [
            SELECT Id
            FROM AuthSession
            WHERE UsersId = :userId AND LoginType = :LOGIN_TYPE
        ];
    }

    @TestVisible
    private List<Database.DeleteResult> deleteAuthSession(
        List<AuthSession> sessions
    ) {
        if (sessions.isEmpty()) {
            return new List<Database.DeleteResult>();
        }

        return Database.delete(sessions, false, System.AccessLevel.SYSTEM_MODE);
    }

    @TestVisible
    private void handleDeleteResult(List<Database.DeleteResult> deleteResults) {
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
    }
}
