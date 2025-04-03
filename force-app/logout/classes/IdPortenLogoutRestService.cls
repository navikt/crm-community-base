@RestResource(urlMapping='/idporten/logout/*')
global class IdPortenLogoutRestService {
    @HttpPost
    global static void logoutBySessionId(String sid) {
        List<IdPortenCache__c> cache = [
            SELECT UserId__c
            FROM IdPortenCache__c
            WHERE Name = :sid
        ];

        if (cache.size() > 0) {
            //delete users all active sessions
            try {
                delete [
                    SELECT Id
                    FROM AuthSession
                    WHERE
                        UsersId = :cache[0].UserId__c
                        AND LoginType = 'Chatter Communities External User Third Party SSO'
                ];
            } catch (Exception e) {
                LoggerUtility logger = new LoggerUtility('Logout');
                logger.critical(
                    'Could not delete AuthSession while logging out user. \n' +
                    e.getMessage(),
                    null,
                    CRM_ApplicationDomain.Domain.CRM
                );
                logger.publish();
            }
        }
    }
}
