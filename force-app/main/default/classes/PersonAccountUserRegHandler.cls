global class PersonAccountUserRegHandler implements Auth.RegistrationHandler{

    global User createUser(Id portalId, Auth.UserData data){
        String nationalIdentityNumber=data.attributeMap.get('pid');
        return CommunityUsersService.getOrCreatePersonAccountUser(nationalIdentityNumber);
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    }
}