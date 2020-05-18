public with sharing class CommunityUsersService {

    public static User getOrCreatePersonAccountUser(String personIdent) {
        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>{
                personIdent
        });
        if (existingUsers.size() > 0) return existingUsers[0];

        DefaultCommunityProfile__c defaultCommunityProfiles=DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        List<Account> personAccounts=new AccountsSelector_Community().selectByIdent(new Set<String>{personIdent});
        if (personAccounts.size()>0 && profile != null) {
            PersonAccountWrapper contact=new PersonAccountWrapper(personAccounts[0]);
            User user= createCommunityUser(contact, profile.Id);
            String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
            List<PermissionSet> permissionSets=[SELECT Id FROM permissionSet WHERE Name=:permissionSetName];
           if(permissionSets.size()>0){
                PermissionSetAssignment permSetAssignment=new PermissionSetAssignment(AssigneeId=user.Id, PermissionSetId=permissionSets[0].Id);
                insert permSetAssignment;
            }
            return user;
        }

        return null;
    }

    @TestVisible
    private static User createCommunityUser(PersonAccountWrapper contact, Id profileId){
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