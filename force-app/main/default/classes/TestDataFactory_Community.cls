@IsTest
public class TestDataFactory_Community {

    public static final Id PERSON_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    private static List<User> users;
    private static List<Account> personAccounts;


    public static List<User> getEmployerCommunityUser(Set<Id> personAccountsIds, Boolean doInsert) {
        List<Account> personAccounts = [SELECT Id, FirstName, LastName, PersonContactId FROM Account WHERE Id IN :personAccountsIds];
        Profile communityProfile = [SELECT Name FROM Profile WHERE Name='Personbruker Login' OR Name='Trial Customer Portal User' LIMIT 1];

        List<User> users = new List<User>();
        for (Account pa : personAccounts) {
            String email = pa.PersonContactId + '@nav.apextest';
            User u = new User();
            u.FirstName = pa.FirstName;
            u.LastName = pa.LastName;
            u.ContactId = pa.PersonContactId;
            u.Alias =  String.valueOf(pa.PersonContactId).substring(1,6);
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

    public static List<Account> getPersonAccounts(Integer numberOfAccounts) {
        if (personAccounts != null) return personAccounts;
        personAccounts = new List<Account>();
        List<Person__c> persons=getPersons(numberOfAccounts);
        for (Integer i = 1; i <= numberOfAccounts; i++) {
            personAccounts.add(new Account(
                    FirstName = 'Person',
                    LastName = String.valueOf(i),
                    INT_PersonIdent__c = String.valueOf(i),
                    CRM_Person__c=persons[i-1].Id,
                    RecordTypeId = PERSON_ACCOUNT_RECORDTYPEID
            ));
        }
        personAccounts=[SELECT FirstName, LastName, INT_PersonIdent__c, CRM_Person__c FROM Account WHERE  RecordTypeId =: PERSON_ACCOUNT_RECORDTYPEID];
        return personAccounts;
    }

    private static List<Person__c> getPersons(Integer numberOfPersons){
        List<Person__c> persons=new List<Person__c>();
        for (Integer i = 1; i <= numberOfPersons; i++) {
            persons.add(new Person__c(
                Name=String.valueOf(i)
            ));
        }
        insert persons;
        return persons;
    }

    public static List<User> getUsers(Integer numberOfUsers, String profileName, Boolean assignRole, Boolean doInsert) {
        if (users != null) return users;
        users = new List<User>();
        Profile profile = [SELECT Id, UserLicense.Name FROM Profile WHERE Name = :profileName LIMIT 1];

        for (Integer i = 1; i <= numberOfUsers; i++) {
            String firstName = 'User';
            String lastName = String.valueOf(i);
            String email = firstName + lastName + '@nav.apextest';
            User user = new User(
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email,
                    Username = email,
                    Alias = lastName,
                    LanguageLocaleKey = 'no',
                    LocaleSidKey = 'no_NO',
                    TimeZoneSidKey = 'Europe/Paris',
                    EmailEncodingKey = 'UTF-8',
                    ProfileId = profile.Id
            );
            if (assignRole) {
                UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Default'];
                user.UserRoleId = role.Id;
            }
            users.add(user);

        }
        if (doInsert) insert users;
        return users;
    }
}