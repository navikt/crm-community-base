@IsTest
private class UsersSelector_CommunityTest {

    @IsTest
    private static void selectByAccountIdent(){
        User navEmployee=TestDataFactory_Community.getUsers(1,'System Administrator',true,true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(1)[0];
            TestDataFactory_Community.getEmployerCommunityUser(new Set<Id>{
                    personAccount.Id
            }, true);

            Test.startTest();
            List<User> users = new UsersSelector_Community().selectByAccountIdent(new Set<String>{
                    personAccount.INT_PersonIdent__c
            });
            Test.stopTest();
            System.assertEquals(1, users.size());
        }
    }
}