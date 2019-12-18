private class PersonAccountsSelectorTest {

    @IsTest
    private static void selectByIdent() {
        List<Account> personAccountsTestData = TestDataFactory.getPersonAccounts(2, true);

        Test.startTest();
        List<Account> personAccounts = new PersonAccountsSelector().selectByIdent(new Set<String> {personAccountsTestData[0].INT_Ident__c});
        Test.stopTest();

        System.assertEquals(1, personAccounts.size());
    }
}