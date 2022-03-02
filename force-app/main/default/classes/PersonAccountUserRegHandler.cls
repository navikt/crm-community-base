global class PersonAccountUserRegHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        system.debug(portalId);
        system.debug(data);
        system.debug(data.attributeMap);
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
        
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //return community plus login user
            return CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
        }
        User user= CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
        if(user==null){
            user=CommunityUsersService.getOrCreatePersonAccountUserWithConfidentialAddress(personIdent);
        }
        if(communityId=='0DB2o000000Ug9I' || communityId=='0DB1l0000008QNv' || communityId=='0DB2o000000Ug9D'){
            CommunityUsersService.assignCommunitySpecificPermissionSet(user.Id,communityId);
        }

        String sid=data.attributeMap.get('sid');
        logSession(sid,user.Id);
        return user;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        system.debug(portalId);
        system.debug(data);
        system.debug(data.attributeMap);
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
        String sid=data.attributeMap.get('sid');
        logSession(sid,userid);
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //update community plus login user
            CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
        }

        if(communityId=='0DB2o000000Ug9I' || communityId=='0DB1l0000008QNv' || communityId=='0DB2o000000Ug9D'){
            CommunityUsersService.assignCommunitySpecificPermissionSet(userId,communityId);
        }
    }

    private static void logSession(string sid, Id userId){
        if(sid!=null){
            IdPortenSession__c session=new IdPortenSession__c();
            session.Name=sid;
            session.UserId__c=userId;
            insert session;
        }
    }
}