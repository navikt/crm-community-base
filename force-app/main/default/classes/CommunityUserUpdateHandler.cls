public without sharing class CommunityUserUpdateHandler extends MyTriggers {
    
    public override void onAfterUpdate(Map<Id, SObject> triggerOldMap) {
        List<String> fieldNamesToCheck = new String[]{'INT_LastName__c', 'INT_FirstName__c', 'INT_MiddleName__c'};
        Set<Id> personIdsWithChangedName= new Set<Id>();
        for(Person__c person:(List<Person__c>) records){
            if (MyTriggers.hasChangedFields(fieldNamesToCheck,person,triggerOldMap.get(person.Id)) && person.CRM_Account__c!=null){
                personIdsWithChangedName.add(person.Id);
            }
        }
        if(personIdsWithChangedName.size()>0){
            createAsyncRequestJob(personIdsWithChangedName);
        }    
    }

    private void createAsyncRequestJob(Set<Id> personIds){
        Map<Id,Person__c> personsWithChangedName=new Map<Id,Person__c>();
        for(Person__c person:[SELECT CRM_Account__c, INT_LastName__c, INT_FirstName__c,	INT_MiddleName__c FROM Person__c WHERE Id in:personIds]){
            personsWithChangedName.put(person.CRM_Account__c, person);
        }

        List<User> usersToUpdate=new UsersSelector_Community().selectByAccountId(personsWithChangedName.keyset());
        String params='';
        Integer i=0;
        for(User user:usersToUpdate){
            params+=user.AccountId;
            i++;
            //if(i<usersToUpdate.size()){
            //    params+=', ';
            //}
        }

        if(usersToUpdate.size()>0){
            AsyncRequest__c req=new AsyncRequest__c();
        	req.CRM_ApexJobType__c='Queueable';
        	req.CRM_AsyncType__c='Community User Update';
        	req.CRM_Params__c=params;
        	insert req;
        }
    }
}

