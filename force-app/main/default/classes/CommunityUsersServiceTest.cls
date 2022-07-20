@IsTest
private class CommunityUsersServiceTest {
    @TestSetup
    private static void setupTestData() {
        Profile communityProfile = [
            SELECT Name
            FROM Profile
            WHERE Name = 'Personbruker Login' OR Name = 'Trial Customer Portal User'
            LIMIT 1
        ];

        Profile communityPlusLoginProfile = [
            SELECT Name
            FROM Profile
            WHERE Name = 'Samhandler Login' OR Name = 'Trial Customer Portal User'
            LIMIT 1
        ];

        
        DefaultCommunityProfile__c defaultCommunityProfile = new DefaultCommunityProfile__c(
            DefaultProfile__c = communityProfile.Name,
            DefaultPermissionSet__c = 'CRM_ManageAsyncRequests',
            DefaultCommunityPlusProfile__c = 'Trial Customer Portal User',
            DefaultCommunityPlusPermissionSetGroup__c = 'Test',
            DefaultCommunityPlusLoginPermSet__c='TestCommunity',
            DefaultCommunityPlusLoginProfile__c=communityPlusLoginProfile.Name
        );
        insert defaultCommunityProfile;
    }

    @IsTest
    private static void getOrCreatePersonAccountUser_whenUserExist() {
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];

            TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, 'Personbruker Login', true);

            Test.startTest();
            User user = CommunityUsersService.getOrCreatePersonAccountUser('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);
        }
    }

    @IsTest
    private static void getOrCreatePersonAccountUser_whenUserIsCreated() {
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];

            Test.startTest();
            User user = CommunityUsersService.getOrCreatePersonAccountUser('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);
            List<PermissionSet> permissionSets = [SELECT Id FROM permissionSet WHERE Name = 'CRM_ManageAsyncRequests'];
            System.assertEquals(
                1,
                [
                    SELECT COUNT()
                    FROM PermissionSetAssignment
                    WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSets[0].Id
                ]
            );
        }
    }

    @IsTest
    private static void getOrCreatePersonAccountUser_whenNoUserOrPersonAccountExist() {
        Test.startTest();
        User user = CommunityUsersService.getOrCreatePersonAccountUser('1');
        Test.stopTest();
        System.assert(user == null);
    }

    @IsTest
    private static void createCommunityUser() {
        User officeUser = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(officeUser) {
            TestDataFactory_Community.getPersonAccounts(1);
        }

        Id contactId = [SELECT PersonContactId FROM Account LIMIT 1].PersonContactId;
        PersonAccountWrapper wrapper = new PersonAccountWrapper();
        wrapper.recordId = contactId;
        wrapper.firstName = 'Test';
        wrapper.lastName = 'User';
        Profile communityProfile = [
            SELECT Name
            FROM Profile
            WHERE Name = 'Personbruker Login' OR Name = 'Trial Customer Portal User'
            LIMIT 1
        ];

        Test.startTest();
        User user = CommunityUsersService.createCommunityUser(wrapper, communityProfile.Id);
        Test.stopTest();

        System.assertEquals(contactId + '@portal.nav.no', user.Username);
        System.assertEquals(contactId + '@portal.nav.no', user.Email);
        System.assertEquals('Test', user.FirstName);
        System.assertEquals('User', user.LastName);
    }

    @IsTest 
    private static void getOrCreatePersonAccountUserWithConfidentialAddress(){
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            Person__c person=[SELECT ID, INT_Confidential__c FROM Person__c WHERE CRM_Account__c=:personAccount.Id];
            person.INT_Confidential__c='FORTROLIG';
            update person;
            Test.startTest();
            User user = CommunityUsersService.getOrCreatePersonAccountUserWithConfidentialAddress('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);
            List<PermissionSet> permissionSets = [SELECT Id FROM permissionSet WHERE Name = 'CRM_ManageAsyncRequests'];
            System.assertEquals(
                0,
                [
                    SELECT COUNT()
                    FROM PermissionSetAssignment
                    WHERE AssigneeId = :user.Id AND PermissionSetId = :permissionSets[0].Id
                ]
            );
        }
    }

    @IsTest
    private static void createCommunityPlusUser() {
        User officeUser = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(officeUser) {
            Person__c person = new Person__c();
            person.INT_Confidential__c = 'Ugradert';
            person.INT_FirstName__c = 'Freelance';
            person.INT_LastName__c = 'Tolk';
            person.Name = '01011800001';
            insert person;
        }

        Test.startTest();
        CommunityUsersService.createCommunityPlusUser(new List<String>{ '01011800001' });
        Test.stopTest();

        User user = [SELECT Id, Name, FirstName, LastName, ProfileId FROM User WHERE Name = 'Freelance Tolk'];
        System.assertEquals('Freelance', user.FirstName);
        System.assertEquals('Tolk', user.LastName);
    }

    @IsTest
    private static void getOrcreateCommunityPlusLoginUser_whenUserDoesNotExisit(){
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            Test.startTest();
            User user = CommunityUsersService.getOrcreateCommunityPlusLoginUser('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);

            PermissionSet permSet=[SELECT Id FROM PermissionSet WHERE Name='TestCommunity' LIMIT 1];
            System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId=:permSet.Id AND AssigneeId=:user.Id], 'Expect perm set to be assigned to new user');
        }
    }

    @IsTest
    private static void getOrcreateCommunityPlusLoginUser_whenCommunityPlusLoginUserExisit(){
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            User existingCommunityUser=TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, 'Samhandler Login', true)[0];
            PermissionSet permSet=[SELECT Id FROM PermissionSet WHERE Name='TestCommunity' LIMIT 1];
            PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                      AssigneeId = existingCommunityUser.Id,
                      PermissionSetId = permSet.Id
                  );
                  insert permSetAssignment;

            Test.startTest();
            User user = CommunityUsersService.getOrcreateCommunityPlusLoginUser('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);

            
            System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId=:permSet.Id AND AssigneeId=:user.Id], 'Expect perm set to be assigned to new user');
        }
    }

    @IsTest
    private static void getOrcreateCommunityPlusLoginUser_whenCommunityUserWithoutPermSetExisit(){
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            User existingCommunityUser=TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, 'Personbruker Login', true)[0];
            
            Test.startTest();
            User user = CommunityUsersService.getOrcreateCommunityPlusLoginUser('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);

            PermissionSet permSet=[SELECT Id FROM PermissionSet WHERE Name='TestCommunity' LIMIT 1];            
            System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId=:permSet.Id AND AssigneeId=:user.Id], 'Expect perm set to be assigned to new user');
        }
    }

    @IsTest
    private static void assignCommunitySpecificPermissionSet(){
        Id permissionSetId = [SELECT Id FROM permissionSet WHERE Name='TestCommunity' LIMIT 1].Id;
        
        Test.startTest();
        CommunityUsersService.assignCommunitySpecificPermissionSet(UserInfo.getUserId(),'0DB1l0000008QNvGAX');
        Test.stopTest();

        System.assertEquals(1,[SELECT COUNT() FROM PermissionSetAssignment WHERE AssigneeId=:UserInfo.getUserId() AND PermissionSetId=:permissionSetId], 'Expect permission set to be assigned');
    }

    @isTest
    private static void createCommununityUserTombstone(){
        
        // Create different test cases
        List<Account> filteredAccounts = TestDataFactory_Community.getPersonAccounts(5);

        // Every account has to have the same PersonIdent
        for (Account a : filteredAccounts) {
            a.INT_PersonIdent__c = '1234';
        }        

        // Set up first test conditions
        for (Account a : filteredAccounts) {
            a.INT_IsHasTombstone__c = true;
        }
        filteredAccounts[0].INT_IsHasTombstone__c = false; 

        Test.startTest();
        List<Account> mergedAccounts = CommunityUsersService.filterAccounts(filteredAccounts);

        // Second test condition
        filteredAccounts[1].INT_IsHasTombstone__c = false;
        List<Account> mergedAccountsBroken = CommunityUsersService.filterAccounts(filteredAccounts);

        // Third test condition
        for (Integer i = 2; i < 5; i++) {
            filteredAccounts[i].INT_IsHasTombstone__c = false;
        }
        List<Account> unmergedAccounts = CommunityUsersService.filterAccounts(filteredAccounts);
        
        Test.stopTest();

        System.assertEquals(1, mergedAccounts.size());
        System.assertEquals(5, unmergedAccounts.size());
        System.assertEquals(2, mergedAccountsBroken.size());

    }
}
