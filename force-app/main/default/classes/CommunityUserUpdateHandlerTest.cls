@IsTest
private class CommunityUserUpdateHandlerTest {

    @TestSetup
    private static void makeData(){
        //we don't want to run triggers when creating test data
        //myTriggers.disable(PersonHandler.class);
        //myTriggers.disable(PersonAccessHandler.class);
        Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
        User communityUser = TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, true)[0];
    }
    
    @IsTest
    private static void updateLastName(){
        //we don't want to test other triggers handlers than CommunityUserUpdateHandler
        //myTriggers.disable(PersonHandler.class);
        //myTriggers.disable(PersonAccessHandler.class);
        
        Person__c person=[SELECT INT_LastName__c, CRM_Account__c FROM Person__c LIMIT 1]; 
        User communityUser=[SELECT LastName FROM User WHERE AccountId =:person.CRM_Account__c LIMIT 1];
        System.assertEquals('1', communityUser.LastName, 'Last name before update');

        Test.startTest();
        person.INT_LastName__c='New last name';
        update person;
        Test.stopTest();

        User updatedUser=[SELECT LastName FROM User WHERE Id=:communityUser.Id LIMIT 1];
        System.assertEquals('New last name', updatedUser.LastName, 'Expect users last name to be same as person');
    }
}
