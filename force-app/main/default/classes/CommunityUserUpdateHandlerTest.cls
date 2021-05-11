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
            List<Account> personAccounts = TestDataFactory_Community.getPersonAccounts(2);
            Map<String,Account> accountByLastName=new Map<String,Account>();
            for(Account acc:personAccounts){
                accountByLastName.put(acc.LastName,acc);
            }

            Set<Id> personAccountIds=new Set<Id>();
            List<Person__c> persons=[SELECT INT_LastName__c, CRM_Account__c FROM Person__c]; 
            for(Person__c person:persons){
                person.CRM_Account__c=accountByLastName.get(person.INT_LastName__c).Id;
                personAccountIds.add(person.CRM_Account__c);
            }
            update persons;
            List<User> users=TestDataFactory_Community.getEmployerCommunityUser(personAccountIds, true);
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

        List<AsyncRequest__c> asyncRequests=[SELECT CRM_Params__c FROM AsyncRequest__c WHERE CRM_AsyncType__c='Community User Update'];
        System.assertEquals(1,asyncRequests.size(), 'Expect 1 async request for updating community user');
        System.assertEquals(person.CRM_Account__c, asyncRequests[0].CRM_Params__c, 'Expect parram to be users account id');
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

        List<AsyncRequest__c> asyncRequests=[SELECT CRM_Params__c FROM AsyncRequest__c WHERE CRM_AsyncType__c='Community User Update'];
        System.assertEquals(1,asyncRequests.size(), 'Expect 1 async request for updating community user');
        System.assertEquals(person.CRM_Account__c, asyncRequests[0].CRM_Params__c, 'Expect parram to be users account id');
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

        List<AsyncRequest__c> asyncRequests=[SELECT CRM_Params__c FROM AsyncRequest__c WHERE CRM_AsyncType__c='Community User Update'];
        System.assertEquals(1,asyncRequests.size(), 'Expect 1 async request for updating community user');
        System.assertEquals(person.CRM_Account__c, asyncRequests[0].CRM_Params__c, 'Expect parram to be users account id');
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
        System.assertEquals(0,[SELECT COUNT() FROM AsyncRequest__c WHERE CRM_AsyncType__c='Community User Update'], 'Expect no async request');
    }

    @IsTest
    private static void updateTwoPersonAccounts(){ 
        Test.startTest();
        List<Person__c> persons=[SELECT INT_LastName__c, CRM_Account__c FROM Person__c LIMIT 2]; 
        for(Person__c person:persons){
            person.INT_LastName__c='New last name';
        }
        update persons;
        Test.stopTest();

        List<AsyncRequest__c> asyncRequests=[SELECT CRM_Params__c FROM AsyncRequest__c WHERE CRM_AsyncType__c='Community User Update'];
        System.assertEquals(1,asyncRequests.size(), 'Expect 1 async request for updating community user');
        
        System.assert(asyncRequests[0].CRM_Params__c.contains(persons[0].CRM_Account__c), 'Expect first account id to be included in params');
        System.assert(asyncRequests[0].CRM_Params__c.contains(persons[1].CRM_Account__c), 'Expect second account id to be included in params');
        System.assert(asyncRequests[0].CRM_Params__c.contains(','), 'Expect comma to be included in params');
    }
}
