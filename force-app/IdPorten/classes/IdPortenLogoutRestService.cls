@RestResource(urlMapping='/idporten/logout/*')
global class IdPortenLogoutRestService {
   
    @HttpPost
    global static void logoutBySessionId(String sid) {
        List<IdPortenCache__c> cache=[SELECT UserId__c FROM IdPortenCache__c WHERE Name=:sid AND Type__c='Session'];

        if(cache.size()>0){
            //delete users all active sessions
            delete [SELECT Id FROM AuthSession WHERE UsersId=:cache[0].UserId__c AND LoginType='Chatter Communities External User Third Party SSO'];
        }
    }
}
