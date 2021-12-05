global class PersonAccountUserRegHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //return community plus login user
            return CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
        }
        User user= CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
        if(communityId=='0DB2o000000Ug9I' || communityId=='0DB1l0000008QNv'){
            CommunityUsersService.assignCommunitySpecificPermissionSet(user.Id,communityId);
        }
        return user;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //update community plus login user
            CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
        }

        if(communityId=='0DB2o000000Ug9I' || communityId=='0DB1l0000008QNv'){
            CommunityUsersService.assignCommunitySpecificPermissionSet(userId,communityId);
        }
    }
}