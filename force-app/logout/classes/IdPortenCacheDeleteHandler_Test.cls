@IsTest
private class IdPortenCacheDeleteHandler_Test {
    

    @IsTest
    private static void testIdPortenCacheDelete(){
        IdPortenCache__c cache=new IdPortenCache__c();    
        cache.Name='sid';
        cache.UserId__c='0051j000009na8sAAA';
        insert cache;

        delete cache;
        system.assertEquals(0,[SELECT COUNT() FROM IdPortenCache__c WHERE Name='sid'], 'Cache is not found');
    }
}