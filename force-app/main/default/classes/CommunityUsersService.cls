public with sharing class CommunityUsersService {
    public static User getOrCreatePersonAccountUser(String personIdent) {
        //check if related Person__c is ugradert
        List<Account> personAccounts = new AccountsSelector_Community().selectByIdent(personIdent);
        if (personAccounts == null || personAccounts.size() == 0)
            return null;

        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>{ personIdent });
        if (existingUsers.size() > 0)
            return existingUsers[0];

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

        if (personAccounts.size() > 0 && profile != null) {
            PersonAccountWrapper contact = new PersonAccountWrapper(personAccounts[0]);
            User user = createCommunityUser(contact, profile.Id);
            String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
            String permissionSetGroupName = defaultCommunityProfiles.DefaultPermissionSetGroup__c;
            List<PermissionSet> permissionSets = [SELECT Id FROM permissionSet WHERE Name = :permissionSetName];
            if (permissionSets.size() > 0) {
                PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                    AssigneeId = user.Id,
                    PermissionSetId = permissionSets[0].Id
                );
                insert permSetAssignment;
            }
            List<PermissionSetGroup> permsetGroups = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName =: permissionSetGroupName];
            if(!permsetGroups.isEmpty()){
                PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                    AssigneeId = user.Id,
                    PermissionSetGroupId = permsetGroups[0].Id
                );
                insert permSetAssignment;
            }
            return user;
        }

        return null;
    }

    @TestVisible
    private static User createCommunityUser(PersonAccountWrapper contact, Id profileId) {
        User user = new User();
        user.FirstName = contact.firstName;
        user.MiddleName = contact.middleName;
        user.LastName = contact.lastName;
        user.Username = contact.recordId + '@nav.portal';
        user.Email = contact.recordId + '@nav.portal';
        String contactIdString = (String) contact.recordId;
        user.Alias = contactIdString.right(8);
        user.TimeZoneSidKey = 'Europe/Paris';
        user.LocaleSidKey = 'no_NO';
        user.LanguageLocaleKey = 'no';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = profileId;
        user.ContactId = contact.recordId;
        insert user;
        return user;
    }

    @InvocableMethod(label='Create Community Plus User')
    public static List<User> createCommunityPlusUser(List<String> personIdents) {
        String personIdent = personIdents[0];
        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>{ personIdent });
        User user;

        if (existingUsers.isEmpty()) {
            user = getOrCreatePersonAccountUser(personIdent);
            existingUsers.add(user);
        } else {
            user = existingUsers[0];
        }

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultCommunityPlusProfile__c;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        user.ProfileId = profileId;
        update user;

        String permissionSetGroupName = defaultCommunityProfiles.DefaultCommunityPlusPermissionSetGroup__c;
        Id permissionSetGroupId = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permissionSetGroupName].Id;
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
            AssigneeId = user.Id,
            PermissionSetGroupId = permissionSetGroupId
        );
        insert permSetAssignment;

        return existingUsers;
    }

    public static User getOrcreateCommunityPlusLoginUser(String personIdent) {
          //check if related Person__c is ugradert
          List<Account> personAccounts = new AccountsSelector_Community().selectByIdent(personIdent);
          if (personAccounts == null || personAccounts.size() == 0)
              return null;
  
              DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
              String profileName = defaultCommunityProfiles.DefaultCommunityPlusLoginProfile__c;
              Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

              String permissionSetName = defaultCommunityProfiles.DefaultCommunityPlusLoginPermSet__c;
              List<PermissionSet> permissionSets = [SELECT Id FROM permissionSet WHERE Name = :permissionSetName];

          List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>{ personIdent });
            if(existingUsers.size()>0)
                return assignCommunityPlusLoginProfileAndPermSetToExistingUser(existingUsers[0], profile.Id, permissionSets[0].Id);


          if (personAccounts.size() > 0 && profile != null) {
              PersonAccountWrapper contact = new PersonAccountWrapper(personAccounts[0]);
              User user = createCommunityUser(contact, profile.Id);
            

              if (permissionSets.size() > 0) {
                  PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                      AssigneeId = user.Id,
                      PermissionSetId = permissionSets[0].Id
                  );
                  insert permSetAssignment;
              }
              return user;
          }
  
          return null;
    }

    private static User assignCommunityPlusLoginProfileAndPermSetToExistingUser(User user, Id plusLoginProfileId, Id permissionSetId){
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String communityProfileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name = :communityProfileName];
        //check if user don't have community plus
        if(user.ProfileId==communityProfile.Id){
            user.ProfileId=plusLoginProfileId;
        }

        //check if user has community plus login perm set
        List<PermissionSetAssignment> assignments=[SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId=:permissionSetId AND AssigneeId=:user.Id];
        if(assignments.size()==0){
            PermissionSetAssignment newAssignment=new PermissionSetAssignment(PermissionSetId=permissionSetId, AssigneeId=user.Id);
            insert newAssignment;
        }

        return user;
    }
}
        
        