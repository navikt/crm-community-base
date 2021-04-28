public without sharing class CommunityUserUpdateHandler extends MyTriggers {
    
    public override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        List<String> fieldNamesToCheck = new String[]{'INT_LastName__c'};
        system.debug('start');
        Map<Id,Person__c> personsWithChangedName=new Map<Id,Person__c>();

        for(Person__c person:(List<Person__c>) records){
            System.debug(person.INT_LastName__c);
            Person__C oldPerson=(Person__c)triggerOldMap.get(person.Id);
            System.debug(oldPerson.INT_LastName__c);
            if (MyTriggers.hasChangedFields(fieldNamesToCheck,person,triggerOldMap.get(person.Id)) && person.CRM_Account__c!=null){
                personsWithChangedName.put(person.CRM_Account__c, person);
            }
        }
        System.debug(personsWithChangedName);
        List<User> usersToUpdate=new UsersSelector_Community().selectByAccountId(personsWithChangedName.keyset());
        for(User user:usersToUpdate){
            Person__c person=personsWithChangedName.get(user.AccountId);
            system.debug(person);
            user.LastName=person.INT_LastName__c;
        }
        //update usersToUpdate;
        system.debug(usersToUpdate.size());
        system.debug(usersToUpdate);
    }
}

