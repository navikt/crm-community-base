@IsTest
private class CommunityUserAsyncRequestHandlerTest {

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
            List<Id> accountIds=new List<Id>();
            List<Person__c> persons=[SELECT INT_LastName__c, CRM_Account__c FROM Person__c]; 
            for(Person__c person:persons){
                person.CRM_Account__c=accountByLastName.get(person.INT_LastName__c).Id;
                personAccountIds.add(person.CRM_Account__c);
                accountIds.add(person.CRM_Account__c);
                //change last name
                person.INT_LastName__c='New last name';
            }
            update persons;

            //create async request
            AsyncRequest__c req=new AsyncRequest__c();
            req.CRM_ApexJobType__c='Queueable';
            req.CRM_AsyncType__c='Community User Update';
            req.CRM_Params__c=accountIds[0] + ',' + accountIds[1];
            insert req;

            List<User> users=TestDataFactory_Community.getEmployerCommunityUser(personAccountIds, 'Personbruker Login', true);
        }
    }

    @IsTest
    private static void updateTwoLastNames(){ 
        Set<Id> personAccountIds=new Set<Id>();
        for(Person__c person:[SELECT CRM_Account__c FROM Person__c]){
            personAccountIds.add(person.CRM_Account__c);
        }

        Test.startTest();
        AsyncRequest__c  req=[SELECT CRM_ApexJobType__c, CRM_AsyncType__c, CRM_Params__c FROM AsyncRequest__c LIMIT 1];
        CommunityUserAsyncRequestHandler handler=new CommunityUserAsyncRequestHandler();
		handler.execute(req);
        Test.stopTest();

        List<User> updatedUsers=[SELECT LastName FROM User WHERE AccountId in:personAccountIds];
        System.assertEquals(2, updatedUsers.size(), 'Expect two updated community users');
        for(User user:updatedUsers){
            System.assertEquals('New last name', user.LastName, 'Expect users last name to be same as person');
        }
    }
}
