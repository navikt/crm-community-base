public with sharing class CommunityUsersService {

    public static User getOrCreatePersonAccountUser(String personIdent){
        // check if related Person__c is ugradert
        // Boolean is used to select correct method
        Boolean confidential = false;
        List<Account> personAccounts = new AccountsSelector_Community().selectByIdent(personIdent);        
        if (personAccounts == null || personAccounts.isEmpty()){
            personAccounts = new AccountsSelector_Community().selectByIdentIgnoreConfidential(personIdent);
            confidential = true;
        }
        if (personAccounts == null || personAccounts.isEmpty()) return null;

        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>{ personIdent });
        if (existingUsers.size() > 0) return existingUsers[0];

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

        if (profile != null) {
            //Filter accounts and raise warnings
            List<Account> filteredAccounts = filterAccounts(personAccounts);

            PersonAccountWrapper contact = !filteredAccounts.isEmpty() ? new PersonAccountWrapper(filteredAccounts[0]) : new PersonAccountWrapper(personAccounts[0]);
            User user = createCommunityUser(contact, profile.Id);
            if(confidential) return user;

            String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
            List<PermissionSet> permissionSets = [SELECT Id FROM permissionSet WHERE Name = :permissionSetName];
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

    @TestVisible
    private static User createCommunityUser(PersonAccountWrapper contact, Id profileId) {
        User user = new User();
        user.FirstName = contact?.firstName != null ? contact?.firstName.left(40) : null;
        user.MiddleName = contact?.middleName != null ? contact?.middleName.left(40) : null;
        user.LastName = contact?.lastName != null ? contact?.lastName.left(80) : null;
        user.Username = contact.recordId + '@portal.nav.no';
        user.Email = contact.recordId + '@portal.nav.no';
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
        if (personAccounts == null || personAccounts.isEmpty()) return null;
  
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultCommunityPlusLoginProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

        String permissionSetName = defaultCommunityProfiles.DefaultCommunityPlusLoginPermSet__c;
        List<PermissionSet> permissionSets = [SELECT Id FROM permissionSet WHERE Name = :permissionSetName];

        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>{ personIdent });
        if(existingUsers.size()>0)
            return assignCommunityPlusLoginProfileAndPermSetToExistingUser(existingUsers[0], profile.Id, permissionSets[0].Id);


        if (personAccounts.size() > 0 && profile != null) {            
            //Filter accounts and raise warnings
            List<Account> filteredAccounts = filterAccounts(personAccounts);

            PersonAccountWrapper contact = new PersonAccountWrapper(filteredAccounts[0]);
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

    public static void assignCommunitySpecificPermissionSet(Id userId, Id communityId){
           List<DefaultCommunityPermissionSet__mdt> defaultPermissionSets=[SELECT PermissionSetId__c FROM DefaultCommunityPermissionSet__mdt WHERE NetworkId__c=:communityId];
           
           if(Test.isRunningTest()){
            DefaultCommunityPermissionSet__mdt defaultPermSet=new DefaultCommunityPermissionSet__mdt();
            defaultPermSet.PermissionSetId__c=[SELECT Id FROM permissionSet WHERE Name='TestCommunity' LIMIT 1].Id;
            defaultPermSet.NetworkId__c='0DB1l0000008QNvGAX';
            defaultPermissionSets.add(defaultPermSet);
           }
           
           if(defaultPermissionSets.size()==0){
                return;
           } 

           List<PermissionSetAssignment> assignments=[SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:userId AND PermissionSetId=:defaultPermissionSets[0].PermissionSetId__c];
           if(assignments.size()==0){
               PermissionSetAssignment assignment=new PermissionSetAssignment();
               assignment.AssigneeId=userId;
               assignment.PermissionSetId=defaultPermissionSets[0].PermissionSetId__c;
               insert assignment;
           }
           
    }

    // Filters Accounts for merged accounts without INT_IsHasTombstone__c. Raises appropriate warnings if necessary.
    @TestVisible
    private static List<Account> filterAccounts(List<Account> personAccounts){
        LoggerUtility logger = new LoggerUtility();
        List<Account> filteredAccounts = new List<Account>();
        for(Account a : personAccounts){
            if(!a.INT_IsHasTombstone__c) filteredAccounts.add(a);
        }
        if(filteredAccounts.size() == personAccounts.size() && personAccounts.size() > 1)
            logger.error('User is pre-merge and has multiple accounts. Please ensure everything is correct.', null, CRM_ApplicationDomain.Domain.CRM);
        if(filteredAccounts.size() > 1 && filteredAccounts.size() < personAccounts.size())
            logger.error('User had accounts merged but still has multiple unmerged Accounts.', null, CRM_ApplicationDomain.Domain.CRM);
        if(filteredAccounts.isEmpty())
            logger.critical('All accounts of the user are marked as merged. Please investigate.', null, CRM_ApplicationDomain.Domain.CRM);
        if(logger.peek() != null) logger.publish();
        return filteredAccounts.isEmpty() ? personAccounts : filteredAccounts;
    }
}