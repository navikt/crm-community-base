@IsTest
private class UsersTest {

    @IsTest
    private static void createCommunityUser() {
        User officeUser = TestDataFactory.getUsers(1, 'System Administrator',true, true)[0];
        System.runAs(officeUser) {
            TestDataFactory.getPersonAccounts(1, true);
        }

        Id contactId = [SELECT PersonContactId FROM Account LIMIT 1].PersonContactId;
        ContactWrapper wrapper = new ContactWrapper();
        wrapper.contactId = contactId;
        wrapper.firstName = 'Test';
        wrapper.lastName = 'User';
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Employer'];

        Test.startTest();
        User user = new Users().createCommunityUser(wrapper, communityProfile.Id);
        Test.stopTest();

        System.assertEquals(contactId + '@nav.portal', user.Username);
        System.assertEquals(contactId + '@nav.portal', user.Email);
        System.assertEquals('Test', user.FirstName);
        System.assertEquals('User', user.LastName);
    }
}