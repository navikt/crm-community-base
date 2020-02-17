public with sharing class CommunityUsersService {

    public static User getOrCreatePersonAccountUser(String nationalIdentityNumber) {
        List<User> existingUsers = new UsersSelector().selectByAccountIdent(new Set<String>{
                nationalIdentityNumber
        });
        if (existingUsers.size() > 0) return existingUsers[0];

        DefaultCommunityProfile__c defaultCommunityProfiles=DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.PersonAccountDefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        List<Account> personAccounts=new AccountsSelector().selectByIdent(new Set<String>{nationalIdentityNumber});

        if (personAccounts.size()>0 && profile != null) {
            SobjectWrapper contact=new SobjectWrapper(personAccounts[0]);
            return createCommunityUser(contact, profile.Id);
        }

        return null;
    }

    @TestVisible
    private static User createCommunityUser(SobjectWrapper contact, Id profileId){
        User user=new User();
        user.FirstName=contact.firstName;
        user.LastName=contact.lastName;
        user.Username=contact.recordId + '@nav.portal';
        user.Email=contact.recordId + '@nav.portal';
        String contactIdString=(String)contact.recordId;
        user.Alias=contactIdString.right(8);
        user.TimeZoneSidKey = 'Europe/Paris';
        user.LocaleSidKey = 'no_NO';
        user.LanguageLocaleKey = 'no';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId=profileId;
        user.ContactId=contact.recordId;
        insert user;
        return user;
    }
}