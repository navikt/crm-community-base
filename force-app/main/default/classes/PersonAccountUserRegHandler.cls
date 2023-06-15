global class PersonAccountUserRegHandler implements Auth.RegistrationHandler {
    private List<Id> samhandlerNetworkIds=new List<Id>{'0DB7U000000TN3u','0DB5t00000001tH'};
    global User createUser(Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId = defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if (
            communityId != null &&
            defaultCommunityPlusLoginCommunityId != null &&
            (communityId == defaultCommunityPlusLoginCommunityId || samhandlerNetworkIds.contains(communityId))
        ) {
            //return community plus login user
            User user = CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
            //check for specific permission set for samhandler
            if(samhandlerNetworkIds.contains(communityId)){
                CommunityUsersService.assignCommunitySpecificPermissionSet(user.Id, communityId);
            }
            return user;
        }
        User user = CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
        if (communityId == '0DB2o000000Ug9I' || communityId == '0DB1l0000008QNv' || communityId == '0DB2o000000Ug9D') {
            CommunityUsersService.assignCommunitySpecificPermissionSet(user.Id, communityId);
        }

        return user;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId = defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if (
            communityId != null &&
            defaultCommunityPlusLoginCommunityId != null &&
            (communityId == defaultCommunityPlusLoginCommunityId || samhandlerNetworkIds.contains(communityId))
        ) {
            //update community plus login user
            CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
            //check for specific permission set for samhandler
            if(samhandlerNetworkIds.contains(communityId)){
                CommunityUsersService.assignCommunitySpecificPermissionSet(userId, communityId);
            }
        }

        if (communityId == '0DB2o000000Ug9I' || communityId == '0DB1l0000008QNv' || communityId == '0DB2o000000Ug9D') {
            CommunityUsersService.assignCommunitySpecificPermissionSet(userId, communityId);
        }
    }
}
