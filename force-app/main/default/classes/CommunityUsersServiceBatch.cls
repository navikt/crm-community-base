public with sharing class CommunityUsersServiceBatch {
    public static List<User> getOrCreatePersonAccountUser(List<String> personIdents) {
        List<User> existingUsers = [
            SELECT Id, Name, FirstName, LastName, ProfileId, Account.INT_PersonIdent__c
            FROM User
            WHERE Account.INT_PersonIdent__c IN :personIdents
        ];
        List<String> newIdents = new List<String>(personIdents);
        if (existingUsers.size() == personIdents.size()) {
            return existingUsers;
        } else {
            for (User existingUser : existingUsers) {
                newIdents.remove(newIdents.indexOf(existingUser.Account.INT_PersonIdent__c));
            }
        }

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
        PermissionSet permissionSet = [SELECT Id FROM permissionSet WHERE Name = :permissionSetName LIMIT 1];

        List<Account> personAccounts = [
            SELECT Id, PersonContactId, Name, FirstName, MiddleName, LastName, INT_PersonIdent__c, CRM_Person__c
            FROM Account
            WHERE INT_PersonIdent__c IN :newIdents AND CRM_Person__r.INT_Confidential__c = 'UGRADERT'
        ];

        List<User> newUsers = new List<User>();
        List<PermissionSetAssignment> permsetAssignments = new List<PermissionSetAssignment>();

        if (personAccounts.size() > 0 && profile != null) {
            for (Account personAccount : personAccounts) {
                PersonAccountWrapper contact = new PersonAccountWrapper(personAccount);
                User user = createCommunityUser(contact, profile.Id);
                newUsers.add(user);
                existingUsers.add(user);
            }
            insert newUsers;
            for (User user : newUsers) {
                if (permissionSet != null) {
                    PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                        AssigneeId = user.Id,
                        PermissionSetId = permissionSet.Id
                    );
                    permsetAssignments.add(permSetAssignment);
                }
            }
            insert permsetAssignments;
            return existingUsers;
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
        return user;
    }

    @InvocableMethod(label='Create Community Plus User')
    public static void createCommunityPlusUserFlowAction(List<String> personIdents) {
        createCommunityPlusUser(personIdents);
    }

    public static void createCommunityPlusUser(List<String> personIdents) {
        if (personIdents.size() > 0) {
            List<User> users = getOrCreatePersonAccountUser(personIdents);

            DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
            String profileName = defaultCommunityProfiles.DefaultCommunityPlusProfile__c;
            Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;

            String permissionSetGroupName = defaultCommunityProfiles.DefaultCommunityPlusPermissionSetGroup__c;
            Id permissionSetGroupId = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permissionSetGroupName]
            .Id;
            List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();

            for (User user : users) {
                if (user.ProfileId != profileId) {
                    user.ProfileId = profileId;
                    PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(
                        AssigneeId = user.Id,
                        PermissionSetGroupId = permissionSetGroupId
                    );
                    permSetAssignments.add(permSetAssignment);
                }
            }
            update users;
            insert permSetAssignments;
        }
    }
}
