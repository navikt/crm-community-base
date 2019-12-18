@IsTest
public  class CommunitiesTestDataFactory {

    public static List<User> getEmployerCommunityUser(Set<Id> personAccountsIds, Boolean doInsert) {
        List<Account> personAccounts = [SELECT Id, FirstName, LastName, PersonContactId FROM Account WHERE Id IN :personAccountsIds];
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Employer' LIMIT 1];

        List<User> users = new List<User>();
        for (Account pa : personAccounts) {
            String email = pa.FirstName + pa.LastName + '@nav.apextest';
            User u = new User();
            u.FirstName = pa.FirstName;
            u.LastName = pa.LastName;
            u.ContactId = pa.PersonContactId;
            u.Alias = pa.LastName;
            u.Username = email;
            u.Email = email;
            u.ProfileId = communityProfile.Id;
            u.EmailEncodingKey = 'UTF-8';
            u.CommunityNickname = pa.LastName;
            u.TimeZoneSidKey = 'Europe/Paris';
            u.LocaleSidKey = 'no_NO';
            u.LanguageLocaleKey = 'no';
            users.add(u);
        }
        if (doInsert) insert users;
        return users;
    }
}