public without sharing class CommunityUserAsyncRequestHandler extends AsyncJob {

    public override void execute(AsyncRequest__c ar) {
    
    List<Id> accountIds=ar.CRM_Params__c.split(','); 
    
    //get persons who contains new names
    Map<Id,Person__c> personsWithChangedName=new Map<Id,Person__c>();
    for(Person__c person:[SELECT CRM_Account__c, INT_LastName__c, INT_FirstName__c,	INT_MiddleName__c FROM Person__c WHERE CRM_Account__c in:accountIds]){
        personsWithChangedName.put(person.CRM_Account__c, person);
    }

    //convert account ids to set to be able to user Users Selector class
    Set<Id> accountIdSet=new Set<Id>();
    for(Id accountId:accountIds){
        accountIdSet.add(accountId);
    }

    //update community users with name from Person__c
    List<User> usersToUpdate=new UsersSelector_Community().selectByAccountId(accountIdSet);
        for(User user:usersToUpdate){
            Person__c person=personsWithChangedName.get(user.AccountId);
            user.FirstName=person.INT_FirstName__c;
            user.LastName=person.INT_LastName__c;
            user.MiddleName=person.INT_MiddleName__c;       
        }
        update usersToUpdate;
    }
}
