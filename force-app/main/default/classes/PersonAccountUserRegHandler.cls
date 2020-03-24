global class PersonAccountUserRegHandler implements Auth.RegistrationHandler{

    global User createUser(Id portalId, Auth.UserData data){
        //String nationalIdentityNumber=data.attributeMap.get('pid');
        String communityId=data.attributeMap.get('sfdc_networkid');
        System.debug(communityId);
        String personIdent='12345678901';
        List<User> users=[SELECT Id,FirstName,LastName,ProfileId FROM User WHERE UserName='test.user@nav.comunnity.test'];
        if(users.size()>0){
            setPermissionSets(communityId, users[0].Id);
            return users[0];
        }
        
        return null;
        //return CommunityUsersService.getOrCreatePersonAccountUser(personIdent);
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        //String nationalIdentityNumber=data.attributeMap.get('pid');
        String communityId=data.attributeMap.get('sfdc_networkid');
        System.debug('update ' + communityId);
        setPermissionSets(communityId, userId);
    }

    private void setPermissionSets(String communityId, Id userId){
        
       String permSet1='0PS3N00000052cPWAQ';
       String permSet2='0PS3N00000052cUWAQ';
       String newPermSet='';
       if(communityId=='0DB3N0000004DUR'){
            newPermSet=permSet1;
       }
       else{
            newPermSet=permSet2;
       }
       System.debug(newPermSet);
       List<PermissionSetAssignment> toDelete=[SELECT Id FROM PermissionSetAssignment WHERE AssigneeId=:userId AND (PermissionSetId=:permSet1 OR PermissionSetId=:permSet2)];
       System.debug(toDelete.size());
       delete toDelete;
       PermissionSetAssignment assignment=new PermissionSetAssignment();
       assignment.PermissionSetId=newPermSet;
       assignment.AssigneeId=userId;
       insert assignment;

    }
}