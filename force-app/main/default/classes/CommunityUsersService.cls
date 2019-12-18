public with sharing class CommunityUsersService {

    public static User getOrCreatePersonAccountUser(String nationalIdentityNumber) {
        List<User> existingUsers = new UsersSelector().selectByAccountIdent(new Set<String>{
                nationalIdentityNumber
        });
        if (existingUsers.size() > 0) return existingUsers[0];

        DefaultCommunityProfile__c defaultCommunityProfiles=DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.PersonAccountDefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        List<Account> personAccounts=new PersonAccountsSelector().selectByIdent(new Set<String>{nationalIdentityNumber});

        if (personAccounts.size()>0 && profile != null) {
            ContactWrapper contact=new ContactWrapper(personAccounts[0]);
            return new Users().createCommunityUser(contact, profile.Id);
        }

        return null;
    }
}