@IsTest
private class AccountsSelector_CommunityTest {
    @IsTest
    private static void selectByIdent() {
        List<Account> personAccountsTestData = TestDataFactory_Community.getPersonAccounts(2);

        Test.startTest();
        List<Account> personAccounts = new AccountsSelector_Community()
            .selectByIdent(personAccountsTestData[0].INT_PersonIdent__c);
        Test.stopTest();

        System.assertEquals(1, personAccounts.size());
    }

    @IsTest
    private static void selectByIdentIgnoreConfidential() {
        List<Account> personAccountsTestData = TestDataFactory_Community.getPersonAccounts(2);
        Person__c person=[SELECT ID, INT_Confidential__c FROM Person__c WHERE CRM_Account__c=:personAccountsTestData[0].Id];
        person.INT_Confidential__c='FORTROLIG';
        update person;
        Test.startTest();
        List<Account> personAccounts = new AccountsSelector_Community()
            .selectByIdentIgnoreConfidential(personAccountsTestData[0].INT_PersonIdent__c);
        Test.stopTest();

        System.assertEquals(1, personAccounts.size());
    }
}
