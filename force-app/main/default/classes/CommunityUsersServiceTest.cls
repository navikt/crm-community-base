@IsTest
private class CommunityUsersServiceTest {

    @TestSetup
    private static void setupTestData(){
        Profile communityProfile = [SELECT Name FROM Profile WHERE Name='Personbruker Login' OR Name='Trial Customer Portal User' LIMIT 1];
        DefaultCommunityProfile__c defaultCommunityProfile=new DefaultCommunityProfile__c(PersonAccountDefaultProfile__c=communityProfile.Name, ContactDefaultProfile__c=communityProfile.Name);
        insert defaultCommunityProfile;
    }

    @IsTest
    private static void getOrCreatePersonAccountUser_whenUserExist() {
        User navEmployee=TestDataFactory_Community.getUsers(1,'System Administrator',true,true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1, true)[0];

            TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{
                    personAccount.Id
            }, true);

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
        User navEmployee=TestDataFactory_Community.getUsers(1,'System Administrator',true,true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1, true)[0];

            Test.startTest();
            User user = CommunityUsersService.getOrCreatePersonAccountUser('1');
            Test.stopTest();
            System.assert(user != null);
            System.assertEquals(personAccount.FirstName, user.FirstName);
            System.assertEquals(personAccount.LastName, user.LastName);
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
        User officeUser = TestDataFactory_Community.getUsers(1, 'System Administrator',true, true)[0];
        System.runAs(officeUser) {
            TestDataFactory_Community.getPersonAccounts(1, true);
        }

        Id contactId = [SELECT PersonContactId FROM Account LIMIT 1].PersonContactId;
        PersonAccountWrapper wrapper = new PersonAccountWrapper();
        wrapper.recordId = contactId;
        wrapper.firstName = 'Test';
        wrapper.lastName = 'User';
        Profile communityProfile = [SELECT Name FROM Profile WHERE Name='Personbruker Login' OR Name='Trial Customer Portal User' LIMIT 1];

        Test.startTest();
        User user=CommunityUsersService.createCommunityUser(wrapper, communityProfile.Id);
        Test.stopTest();

        System.assertEquals(contactId + '@nav.portal', user.Username);
        System.assertEquals(contactId + '@nav.portal', user.Email);
        System.assertEquals('Test', user.FirstName);
        System.assertEquals('User', user.LastName);
    }
}