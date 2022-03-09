@IsTest
private class IdPortenLogoutRestService_Test {
   
    @TestSetup
    static void makeData(){
        IdPortenCache__c cache=new IdPortenCache__c();    
        cache.Name='sid';
        cache.UserId__c='0051j000009na8sAAA';
        cache.Type__c='Session';
        insert cache;
    }

    @IsTest
    private static void testLogoutBySessionId_whenSidInCache(){
        IdPortenLogoutRestService.logoutBySessionId('sid');
        system.assertEquals(0,[SELECT COUNT() FROM IdPortenCache__c WHERE Name='sid'], 'Cache is found and deleted');
    }

    @IsTest
    private static void testLogoutBySessionId_whenSidDoNotExistInCache(){
        IdPortenLogoutRestService.logoutBySessionId('sid2');
        system.assertEquals(1,[SELECT COUNT() FROM IdPortenCache__c WHERE Name='sid'], 'Cache is not found and not deleted');
    }
}
