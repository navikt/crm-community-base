@IsTest
private class CommunityUserUpdateHandlerTest {

    @TestSetup
    private static void makeData(){
        //we don't want to run triggers when creating test data
        myTriggers.disable(PersonHandler.class);
        myTriggers.disable(PersonAccessHandler.class);
        myTriggers.disable(CommunityUserUpdateHandler.class);
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            Person__c person=[SELECT CRM_Account__c FROM Person__c LIMIT 1]; 
            person.CRM_Account__c=personAccount.Id;
            update person;
            User communityUser = TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, true)[0];
        }
    }
    
    @IsTest
    private static void updateLastName(){ 
        Test.startTest();
        Person__c person=[SELECT INT_LastName__c, CRM_Account__c FROM Person__c LIMIT 1]; 
        User communityUser=[SELECT LastName FROM User WHERE AccountId =:person.CRM_Account__c LIMIT 1];
        System.assertEquals('1', communityUser.LastName, 'Last name before update');
        person.INT_LastName__c='New last name';
        update person;
        Test.stopTest();

        User updatedUser=[SELECT LastName FROM User WHERE Id=:communityUser.Id LIMIT 1];
        System.assertEquals('New last name', updatedUser.LastName, 'Expect users last name to be same as person');
    }

    @IsTest
    private static void updateFirstName(){ 
        Test.startTest();
        Person__c person=[SELECT INT_FirstName__c, CRM_Account__c FROM Person__c LIMIT 1]; 
        User communityUser=[SELECT FirstName FROM User WHERE AccountId =:person.CRM_Account__c LIMIT 1];
        System.assertEquals('Person', communityUser.FirstName, 'First name before update');
        person.INT_FirstName__c='New first name';
        update person;
        Test.stopTest();

        User updatedUser=[SELECT FirstName FROM User WHERE Id=:communityUser.Id LIMIT 1];
        System.assertEquals('New first name', updatedUser.FirstName, 'Expect users first name to be same as person');
    }

    @IsTest
    private static void updateMiddleName(){ 
        Test.startTest();
        Person__c person=[SELECT INT_MiddleName__c, CRM_Account__c FROM Person__c LIMIT 1]; 
        User communityUser=[SELECT MiddleName FROM User WHERE AccountId =:person.CRM_Account__c LIMIT 1];
        System.assertEquals(null, communityUser.MiddleName, 'Middle name before update');
        person.INT_MiddleName__c='New middle name';
        update person;
        Test.stopTest();

        User updatedUser=[SELECT MiddleName FROM User WHERE Id=:communityUser.Id LIMIT 1];
        System.assertEquals('New middle name', updatedUser.MiddleName, 'Expect users middle name to be same as person');
    }

    @IsTest
    private static void updatePersonWithoutChangingName(){
        Person__c person=[SELECT INT_LastName__c, CRM_Account__c FROM Person__c LIMIT 1]; 
        User communityUser=[SELECT LastName FROM User WHERE AccountId =:person.CRM_Account__c LIMIT 1];
        System.assertEquals('1', communityUser.LastName, 'Last name before update');

        Test.startTest();
        person.INT_IsNavEmployee__c=true;
        update person;
        Test.stopTest();

        User updatedUser=[SELECT LastName FROM User WHERE Id=:communityUser.Id LIMIT 1];
        System.assertEquals('1', updatedUser.LastName, 'Expect last name to be unchanged');
    }
}
