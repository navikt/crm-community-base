global class PersonAccountUserRegHandler implements Auth.RegistrationHandler {
    global User createUser(Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
        String sid=data.attributeMap.get('sid');
        
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //return community plus login user
            User user=CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
            if(sid!=null){
            	logSession(sid,user.id);
        	}
            return user;
        }
        User user= CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
        if(user==null){
            user=CommunityUsersService.getOrCreatePersonAccountUserWithConfidentialAddress(personIdent);
        }
        if(communityId=='0DB2o000000Ug9I' || communityId=='0DB1l0000008QNv' || communityId=='0DB2o000000Ug9D'){
            CommunityUsersService.assignCommunitySpecificPermissionSet(user.Id,communityId);
        }

        if(sid!=null){
            logSession(sid,user.id);
        }
        return user;
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        String personIdent = data.attributeMap.get('pid');
        String communityId = data.attributeMap.get('sfdc_networkid');
        String sid=data.attributeMap.get('sid');
        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String defaultCommunityPlusLoginCommunityId= defaultCommunityProfiles.DefaultCommunityPlusLoginCommunityId__c;
        if(communityId!=null && defaultCommunityPlusLoginCommunityId!=null &&  communityId==defaultCommunityPlusLoginCommunityId){
            //update community plus login user
            CommunityUsersService.getOrcreateCommunityPlusLoginUser(personIdent);
        }

        if(communityId=='0DB2o000000Ug9I' || communityId=='0DB1l0000008QNv' || communityId=='0DB2o000000Ug9D'){
            CommunityUsersService.assignCommunitySpecificPermissionSet(userId,communityId);
        }
        if(sid!=null){
            logSession(sid,userid);
        }
    }

    @future
    public static void logSession(string sid, Id userId){
        IdPortenCache__c cache=new IdPortenCache__c();
        cache.Name=sid;
        cache.UserId__c=userId;
        cache.Type__c='Session';
        try {
            insert cache;   
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
}