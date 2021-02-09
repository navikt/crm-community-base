@IsTest
private class PersonAccountUserRegHandlerTest {
    @IsTest
    private static void createUser() {
        User navEmployee = TestDataFactory_Community.getUsers(
            1,
            'System Administrator',
            true,
            true
        )[0];
        System.runAs(navEmployee) {
            Account personAccount = TestDataFactory_Community.getPersonAccounts(
                1
            )[0];
            TestDataFactory_Community.getEmployerCommunityUser(
                new Set<Id>{ personAccount.Id },
                true
            );

            Map<String, String> attributeMap = new Map<String, String>();
            attributeMap.put('pid', '1');
            Auth.UserData userData = new Auth.UserData(
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                attributeMap
            );

            Test.startTest();
            PersonAccountUserRegHandler regHandler = new PersonAccountUserRegHandler();
            User user = regHandler.createUser(null, userData);
            Test.stopTest();
            System.assert(user != null);
        }
    }

    @IsTest
    private static void updateUser() {
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('pid', '1');
        Auth.UserData userData = new Auth.UserData(
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            attributeMap
        );

        Test.startTest();
        PersonAccountUserRegHandler regHandler = new PersonAccountUserRegHandler();
        regHandler.updateUser(null, null, userData);
        Test.stopTest();
    }
}
