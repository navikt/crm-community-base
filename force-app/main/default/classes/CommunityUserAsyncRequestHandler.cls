public without sharing class CommunityUserAsyncRequestHandler extends AsyncJob {
    public override void execute(AsyncRequest__c ar) {
        Set<Id> accountIdSet = new Set<Id>();
        if (String.isBlank(ar.CRM_Params__c)) {
            return;
        }

        accountIdSet.addAll(((List<Id>) ar.CRM_Params__c.split(',')));

        if (accountIdSet.isEmpty()) {
            return;
        }

        //get persons who contains new names
        Map<Id, Person__c> personsWithChangedName = new Map<Id, Person__c>();
        for (Person__c person : [
            SELECT
                CRM_Account__c,
                INT_LastName__c,
                INT_FirstName__c,
                INT_MiddleName__c,
                INT_IsHasTombstone__c
            FROM Person__c
            WHERE CRM_Account__c IN :accountIdSet
        ]) {
            personsWithChangedName.put(person.CRM_Account__c, person);
        }

        //update community users with name from Person__c
        List<User> usersToUpdate = new UsersSelector_Community()
            .selectByAccountId(accountIdSet);
        for (User user : usersToUpdate) {
            Person__c person = personsWithChangedName.get(user.AccountId);

            user.FirstName = String.isNotBlank(person?.INT_FirstName__c)
                ? person.INT_FirstName__c.left(40)
                : null;
            user.MiddleName = String.isNotBlank(person?.INT_MiddleName__c)
                ? person.INT_MiddleName__c.left(40)
                : null;
            user.LastName = String.isNotBlank(person?.INT_LastName__c)
                ? person.INT_LastName__c.left(80)
                : null;

            if (person.INT_IsHasTombstone__c == true) {
                user.LastName = 'SLETTET';
            }
        }
        update usersToUpdate;
    }
}
