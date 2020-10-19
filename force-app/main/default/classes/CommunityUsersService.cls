public with sharing class CommunityUsersService {

    public static List<User> getOrCreatePersonAccountUser(List<String> personIdents) {
        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>(
                personIdents
        ));
        List<String> newIdents = new List<String>(personIdents);
        if (existingUsers.size() == personIdents.size()) return existingUsers;
        else{
            for(User existingUser:existingUsers){
                newIdents.remove(newIdents.indexOf(existingUser.Account.INT_PersonIdent__c));
            }
        }

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
        List<PermissionSet> permissionSets=[SELECT Id FROM permissionSet WHERE Name=:permissionSetName];

        List<Account> personAccounts=new AccountsSelector_Community().selectByIdent(new Set<String>(newIdents));
        
        List<User> newUsers = new List<User>();
        List<PermissionSetAssignment> permsetAssignments = new List<PermissionSetAssignment>();

        if (personAccounts.size()>0 && profile != null) {   
            for(Account personAccount:personAccounts){
                PersonAccountWrapper contact=new PersonAccountWrapper(personAccount);
                User user= createCommunityUser(contact, profile.Id);
                newUsers.add(user);
                existingUsers.add(user);
            }
            insert newUsers;
            for(User user:newUsers){
                if(permissionSets.size()>0){
                    PermissionSetAssignment permSetAssignment=new PermissionSetAssignment(AssigneeId=user.Id, PermissionSetId=permissionSets[0].Id);
                    permsetAssignments.add(permSetAssignment);
                }
            }
            insert permsetAssignments;
            return existingUsers;
        }
        return null;
    }

    @TestVisible
    private static User createCommunityUser(PersonAccountWrapper contact, Id profileId){
        User user=new User();
        user.FirstName=contact.firstName;
        user.MiddleName=contact.middleName;
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
        return user;
    }

    @InvocableMethod(label='Create Community Plus User')
    public static List<User> createCommunityPlusUser(List<String> personIdents) {
        
        List<User> users = getOrCreatePersonAccountUser(personIdents);
        
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultCommunityPlusProfile__c;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;

        String permissionSetGroupName = defaultCommunityProfiles.DefaultCommunityPlusPermissionSetGroup__c;
        Id permissionSetGroupId = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permissionSetGroupName].Id;
        List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();

        for(User user:users){
            user.ProfileId = profileId;
            PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetGroupId = permissionSetGroupId);
            permSetAssignments.add(permSetAssignment);
        }
        update users;
        insert permSetAssignments;
        
        return users;
    }
}