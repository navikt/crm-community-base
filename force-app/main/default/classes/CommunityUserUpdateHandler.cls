public without sharing class CommunityUserUpdateHandler extends MyTriggers {
    
    public override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        List<String> fieldNamesToCheck = new String[]{'INT_LastName__c'};
        Set<Id> personIdsWithChangedName= new Set<Id>();
        for(Person__c person:(List<Person__c>) records){
            if (MyTriggers.hasChangedFields(fieldNamesToCheck,person,triggerOldMap.get(person.Id)) && person.CRM_Account__c!=null){
                personIdsWithChangedName.add(person.Id);
            }
        }
        if(personIdsWithChangedName.size()>0){
            updateCommunityUser(personIdsWithChangedName);
        }
       
    }

    @future
    private static void updateCommunityUser(Set<Id> personIds){
        Map<Id,Person__c> personsWithChangedName=new Map<Id,Person__c>();
        for(Person__c person:[SELECT CRM_Account__c, INT_LastName__c FROM Person__c WHERE Id in:personIds]){
            personsWithChangedName.put(person.CRM_Account__c, person);
        }

        List<User> usersToUpdate=new UsersSelector_Community().selectByAccountId(personsWithChangedName.keyset());
        for(User user:usersToUpdate){
            Person__c person=personsWithChangedName.get(user.AccountId);
            user.LastName=person.INT_LastName__c;
        }
        update usersToUpdate;
    }
}

