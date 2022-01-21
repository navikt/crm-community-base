@IsTest
private class TestUserSelfRegHandler_Test {

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

            Map<SObjectField, String> registrationAttributes=new  Map<SObjectField, String>();
            Schema.DescribeFieldResult fn = user.firstname.getDescribe();
            Schema.sObjectField fname = fn.getSObjectField();
            registrationAttributes.put(fname, '1');
            

            Test.startTest();
            TestUserSelfRegHandler regHandler = new TestUserSelfRegHandler();
            Id userId = regHandler.createUser(null, null,registrationAttributes,'P8ssword');
            Test.stopTest();
            System.assert(userId != null);

            System.assertEquals(1, [SELECT COUNT() FROM User WHERE Id=:userId],'Expect one user to be created');
        }
    }

}
