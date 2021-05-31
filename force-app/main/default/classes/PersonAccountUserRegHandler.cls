global class PersonAccountUserRegHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //return community plus login user
            CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
        }
        return CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
    }
}
