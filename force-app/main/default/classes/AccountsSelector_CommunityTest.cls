@IsTest
private class AccountsSelector_CommunityTest {

    @IsTest
    private static void selectByIdent() {
        List<Account> personAccountsTestData = TestDataFactory_Community.getPersonAccounts(2, true);

        Test.startTest();
        List<Account> personAccounts = new AccountsSelector_Community().selectByIdent(new Set<String> {personAccountsTestData[0].INT_PersonIdent__c});
        Test.stopTest();

        System.assertEquals(1, personAccounts.size());
    }
}