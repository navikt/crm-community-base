public with sharing class CommunityUsersService {

    public static List<User> getOrCreatePersonAccountUser(List<String> personIdents) {
        List<User> existingUsers = new UsersSelector_Community().selectByAccountIdent(new Set<String>(
                personIdents
        ));
        List<String> newIdents = new List<String>(personIdents);
        if (existingUsers.size() == personIdents.size()) return existingUsers;
        else{
            for(User existingUser:existingUsers){
                newIdents.remove(newIdents.indexOf(existingUser.Account.INT_PersonIdent__c));
            }
        }

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        System.debug(profileName);
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];
        String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
        PermissionSet permissionSet=[SELECT Id FROM permissionSet WHERE Name=:permissionSetName LIMIT 1];

        List<Account> personAccounts=new AccountsSelector_Community().selectByIdent(new Set<String>(newIdents));
        
        List<User> newUsers = new List<User>();
        List<PermissionSetAssignment> permsetAssignments = new List<PermissionSetAssignment>();

        if (personAccounts.size()>0 && profile != null) {   
            for(Account personAccount:personAccounts){
                PersonAccountWrapper contact=new PersonAccountWrapper(personAccount);
                User user= createCommunityUser(contact, profile.Id);
                newUsers.add(user);
                existingUsers.add(user);
            }
            insert newUsers;
            for(User user:newUsers){
                if(permissionSet != null){
                    PermissionSetAssignment permSetAssignment=new PermissionSetAssignment(AssigneeId=user.Id, PermissionSetId=permissionSet.Id);
                    permsetAssignments.add(permSetAssignment);
                }
            }
            insert permsetAssignments;
            return existingUsers;
        }
        return null;
    }

    @TestVisible
    private static User createCommunityUser(PersonAccountWrapper contact, Id profileId){
        User user=new User();
        user.FirstName=contact.firstName;
        user.MiddleName=contact.middleName;
        user.LastName=contact.lastName;
        user.Username=contact.recordId + '@nav.portal';
        user.Email=contact.recordId + '@nav.portal';
        String contactIdString=(String)contact.recordId;
        user.Alias=contactIdString.right(8);
        user.TimeZoneSidKey = 'Europe/Paris';
        user.LocaleSidKey = 'no_NO';
        user.LanguageLocaleKey = 'no';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId=profileId;
        user.ContactId=contact.recordId;
        return user;
    }


    //Splitt opp i to metoder
    @InvocableMethod(label='Create Community Plus User')
    public static List<ServiceResource> createCommunityPlusUserFlowAction(List<String> personIdents) {
        return createCommunityPlusUser(personIdents, 'DummyServiceTerritory');
    }

    public static List<ServiceResource> createCommunityPlusUser(List<String> personIdents, String ServiceTerritoryDeveloperName){
        if(personIdents.size()>0){
            List<User> users = getOrCreatePersonAccountUser(personIdents);
            
            DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
            String profileName = defaultCommunityProfiles.DefaultCommunityPlusProfile__c;
            Id profileId = [SELECT Id FROM Profile WHERE Name = :profileName].Id;
    
            String permissionSetGroupName = defaultCommunityProfiles.DefaultCommunityPlusPermissionSetGroup__c;
            Id permissionSetGroupId = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permissionSetGroupName].Id;
            List<PermissionSetAssignment> permSetAssignments = new List<PermissionSetAssignment>();
    
            for(User user:users){
                user.ProfileId = profileId;
                PermissionSetAssignment permSetAssignment = new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetGroupId = permissionSetGroupId);
                permSetAssignments.add(permSetAssignment);
            }
            update users;
            insert permSetAssignments;
    
            List<ServiceResource> serviceResources = createServiceResource(users, true, serviceTerritoryDeveloperName);
            
            return serviceResources;
        }
        
        return null;
    }

    public static List<ServiceResource> createServiceResource(List<User> users, Boolean isFreelance, String serviceTerritoryDeveloperName) {
        System.debug('createServiceResource');
        List<ServiceResource> serviceResources = new List<ServiceResource>();
        for(User user:users){
            ServiceResource serviceResource = new ServiceResource();
            serviceResource.Name = user.Name;
            serviceResource.ResourceType = 'T';
            serviceResource.IsActive = true;
            serviceResource.put('FSL__GanttLabel__c', isFreelance ? 'Frilanstolk' : 'Ansatt Tolk');
            serviceResource.put('HOT_IsEmployedInterpreter__c', !isFreelance);
            serviceResource.put('HOT_IsFreelanceInterpreter__c', isFreelance);
        }
        insert serviceResources;

        Datetime startDate = Datetime.valueOf('2018-01-01 00:00:00');
        List<Skill> skills = [SELECT Id FROM Skill];
        List<ServiceResourceSkill> serviceResourceSkills = new List<ServiceResourceSkill>();

        ServiceTerritory serviceTerritory = [SELECT Id FROM ServiceTerritory WHERE HOT_DeveloperName__c = :serviceTerritoryDeveloperName];
        List<ServiceTerritoryMember> serviceTerritoryMembers = new List<ServiceTerritoryMember>();

        for(ServiceResource serviceResource:serviceResources){
            for(Skill skill:skills){
                ServiceResourceSkill serviceResourceSkill = new ServiceResourceSkill(
                    ServiceResourceId = serviceResource.Id,
                    SkillId = skill.Id,
                    EffectiveStartDate = startDate 
                );
                serviceResourceSkills.add(serviceResourceSkill);
            }
            if(serviceTerritory != null){
                ServiceTerritoryMember serviceTerritoryMember = new ServiceTerritoryMember(
                    ServiceResourceId = serviceResource.Id, 
                    ServiceTerritoryId = serviceTerritory.Id, 
                    EffectiveStartDate = startDate
                );
                serviceTerritoryMembers.add(serviceTerritoryMember);
            }
        }
        insert serviceResourceSkills;
        insert serviceTerritoryMembers;
        return serviceResources;
    }

}
