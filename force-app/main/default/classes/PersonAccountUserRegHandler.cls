global class PersonAccountUserRegHandler implements Auth.RegistrationHandler{

    global User createUser(Id portalId, Auth.UserData data){
        String personIdent=data.attributeMap.get('pid');
        String communityId=data.attributeMap.get('sfdc_networkid');
        return CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        String personIdent=data.attributeMap.get('pid');
        String communityId=data.attributeMap.get('sfdc_networkid');
    }
}