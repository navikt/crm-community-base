@isTest
private class HOT_CommunityUsersServiceTest {
    @TestSetup
    private static void setup() {
        Profile communityProfile = [
            SELECT Name
            FROM Profile
            WHERE
                Name = 'Personbruker Login'
                OR Name = 'Trial Customer Portal User'
            LIMIT 1
        ];

        Profile communityPlusLoginProfile = [
            SELECT Name
            FROM Profile
            WHERE
                Name = 'Samhandler Login'
                OR Name = 'Trial Customer Portal User'
            LIMIT 1
        ];

        DefaultCommunityProfile__c defaultCommunityProfile = new DefaultCommunityProfile__c(
            DefaultProfile__c = communityProfile.Name,
            DefaultPermissionSet__c = 'CRM_ManageAsyncRequests',
            DefaultCommunityPlusProfile__c = 'Trial Customer Portal User',
            DefaultCommunityPlusPermissionSetGroup__c = 'Test',
            DefaultCommunityPlusLoginPermSet__c = 'TestCommunity',
            DefaultCommunityPlusLoginProfile__c = communityPlusLoginProfile.Name
        );
        insert defaultCommunityProfile;
    }

    @IsTest
    private static void createTjenesteleverandorFormidlerUser() {
        User officeUser = TestDataFactory_Community.getUsers(
            1,
            'System Administrator',
            true,
            true
        )[0];
        System.runAs(officeUser) {
            Person__c person = new Person__c();
            person.INT_Confidential__c = 'Ugradert';
            person.INT_FirstName__c = 'Tjenesteleverandor';
            person.INT_LastName__c = 'Formidler';
            person.Name = '01011800001';
            insert person;
        }

        Test.startTest();
        HOT_CommunityUsersService.createTjenesteleverandorFormidlerUser(
            new List<String>{ '01011800001' }
        );
        Test.stopTest();

        User user = [
            SELECT Id, Name, FirstName, LastName, ProfileId
            FROM User
            WHERE Name = 'Tjenesteleverandor Formidler'
        ];
        System.assertEquals('Tjenesteleverandor', user.FirstName);
        System.assertEquals('Formidler', user.LastName);
    }
}
