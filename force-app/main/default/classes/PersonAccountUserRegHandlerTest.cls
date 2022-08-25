@IsTest
private class PersonAccountUserRegHandlerTest {

    @TestSetup
    private static void makeData(){
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
            DefaultCommunityPlusLoginProfile__c=communityPlusLoginProfile.Name,
            DefaultCommunityPlusLoginCommunityId__c='123'
        );
        insert defaultCommunityProfile;
    }

    @IsTest
    private static void createUser() {
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, 'Personbruker Login', true);

            Map<String, String> attributeMap = new Map<String, String>();
            attributeMap.put('pid', '1');
            Auth.UserData userData = new Auth.UserData('', '', '', '', '', '', '', '', '', '', attributeMap);

            Test.startTest();
            PersonAccountUserRegHandler regHandler = new PersonAccountUserRegHandler();
            User user = regHandler.createUser(null, userData);
            Test.stopTest();
            System.assert(user != null);

            PermissionSet permSet=[SELECT Id FROM PermissionSet WHERE Name='TestCommunity' LIMIT 1];            
            System.assertEquals(0, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId=:permSet.Id AND AssigneeId=:user.Id], 'Expect perm set not to be assigned to community user');
        }
    }

    @IsTest
    private static void createConfidentialUser() {
        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];

            Person__c person = [SELECT INT_Confidential__c FROM Person__c WHERE Id = :personAccount.CRM_Person__c];
            person.INT_Confidential__c = 'FORTROLIG';
            update person;

            Map<String, String> attributeMap = new Map<String, String>();
            attributeMap.put('pid', '1');
            Auth.UserData userData = new Auth.UserData('', '', '', '', '', '', '', '', '', '', attributeMap);

            Test.startTest();
            PersonAccountUserRegHandler regHandler = new PersonAccountUserRegHandler();
            User user = regHandler.createUser(null, userData);
            Test.stopTest();
            user = [SELECT isActive, UserRoleId FROM User WHERE Id = :user.Id];
            System.assert(user != null);
            System.assert(user.isActive == true);

            PermissionSet permSet=[SELECT Id FROM PermissionSet WHERE Name='TestCommunity' LIMIT 1];            
            System.assertEquals(0, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId=:permSet.Id AND AssigneeId=:user.Id], 'Expect perm set not to be assigned to community user');
        }
    }

    @IsTest
    private static void updateUser() {
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('pid', '1');
        Auth.UserData userData = new Auth.UserData('', '', '', '', '', '', '', '', '', '', attributeMap);

        Test.startTest();
        PersonAccountUserRegHandler regHandler = new PersonAccountUserRegHandler();
        regHandler.updateUser(null, null, userData);
        Test.stopTest();
    }

    @IsTest
    private static void createCommunityPlusLoginUser() {


        User navEmployee = TestDataFactory_Community.getUsers(1, 'System Administrator', true, true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{ personAccount.Id }, 'Personbruker Login', true);

            Map<String, String> attributeMap = new Map<String, String>();
            attributeMap.put('pid', '1');
            attributeMap.put('sfdc_networkid', '123');
            Auth.UserData userData = new Auth.UserData('', '', '', '', '', '', '', '', '', '', attributeMap);

            Test.startTest();
            PersonAccountUserRegHandler regHandler = new PersonAccountUserRegHandler();
            User user = regHandler.createUser(null, userData);
            Test.stopTest();
            System.assert(user != null);

            PermissionSet permSet=[SELECT Id FROM PermissionSet WHERE Name='TestCommunity' LIMIT 1];            
            System.assertEquals(1, [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSetId=:permSet.Id AND AssigneeId=:user.Id], 'Expect perm set to be assigned to new user');
        }
    }
}
