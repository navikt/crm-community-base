global class TestUserSelfRegHandler implements Auth.ConfigurableSelfRegHandler {
    private static final String COMMUNITY_ID= '0DB2o000000Ug9D';

    global Id createUser(Id accountId, Id profileId, Map<SObjectField, String> registrationAttributes, String password) {

        String personIdent='';
        for (SObjectField field : registrationAttributes.keySet()) {
			String value = registrationAttributes.get(field);
			if(value!=null) personIdent=value;
		}
        
        List<Account> personAccounts = new AccountsSelector_Community().selectByIdentIgnoreConfidential((personIdent);

        DefaultCommunityProfile__c defaultCommunityProfiles = DefaultCommunityProfile__c.getOrgDefaults();
        String profileName = defaultCommunityProfiles.DefaultProfile__c;
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName];

        if (personAccounts.size() > 0 && profile != null) {
            PersonAccountWrapper contact = new PersonAccountWrapper(personAccounts[0]);
            User user = newCommunityUser(contact, profile.Id, personIdent);
            insert user;

            if(!Test.isRunningTest()){
                Site.validatePassword(user, password, password);
            }            
            
            System.setPassword(user.Id, password);
 
            String permissionSetName = defaultCommunityProfiles.DefaultPermissionSet__c;
            
            if(!Test.isRunningTest()){
                CommunityUsersService.assignCommunitySpecificPermissionSet(user.Id,COMMUNITY_ID);
            }
            return user.Id;
    }
    return null;
}

    private User newCommunityUser(PersonAccountWrapper contact, Id profileId, String personIdent) {
        User user = new User();
        user.FirstName = contact.firstName;
        user.MiddleName = contact.middleName;
        user.LastName = contact.lastName;
        user.Username = personIdent + '@nav.portal';
        user.Email = contact.recordId + '@nav.portal';
        String contactIdString = (String) contact.recordId;
        user.Alias = contactIdString.right(8);
        user.TimeZoneSidKey = 'Europe/Paris';
        user.LocaleSidKey = 'no_NO';
        user.LanguageLocaleKey = 'no';
        user.EmailEncodingKey = 'UTF-8';
        user.ProfileId = profileId;
        user.ContactId = contact.recordId;
        
        return user;
    }
}
