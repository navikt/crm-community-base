@IsTest
private class UsersSelectorTest {

    @IsTest
    private static void selectByAccountIdent(){
        User navEmployee=TestDataFactory.getUsers(1,'System Administrator',true,true)[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory.getPersonAccounts(1, true)[0];
            CommunitiesTestDataFactory.getEmployerCommunityUser(new Set<Id>{
                    personAccount.Id
            }, true);

            Test.startTest();
            List<User> users = new UsersSelector().selectByAccountIdent(new Set<String>{
                    personAccount.INT_Ident__c
            });
            Test.stopTest();
            System.assertEquals(1, users.size());
        }
    }
}