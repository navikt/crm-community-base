public with sharing class HOT_CommunityUsersService {
    @InvocableMethod(label='Create Tjenesteleverandor Formidler User')
    public static List<User> createTjenesteleverandorFormidlerUser(
        List<String> personIdents
    ) {
        String personIdent = personIdents[0];
        List<User> existingUsers = new UsersSelector_Community()
            .selectByAccountIdent(new Set<String>{ personIdent });
        User user;

        if (existingUsers.isEmpty()) {
            user = CommunityUsersService.getOrCreatePersonAccountUser(
                personIdent
            );
            existingUsers.add(user);
        } else {
            user = existingUsers[0];
        }

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultCommunityPlusLoginProfile__c;
        Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
        user.ProfileId = profileId;
        update user;

        Id permissionSetGroupId = [
            SELECT Id
            FROM PermissionSetGroup
            WHERE DeveloperName = 'HOT_Tolk_Tjenesteleverandor_Gruppe'
            LIMIT 1
        ]
        .Id;

        List<PermissionSetAssignment> existingAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE
                AssigneeId = :user.Id
                AND PermissionSetGroupId = :permissionSetGroupId
            LIMIT 1
        ];

        if (existingAssignments.isEmpty()) {
            insert new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetGroupId = permissionSetGroupId
            );
        }

        return existingUsers;
    }
}
