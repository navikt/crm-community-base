public inherited sharing class AccountsSelector_Community extends ApplicationSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Account.Id,
            Account.Name,
            Account.INT_PersonIdent__c,
            Account.PersonContactId,
            Account.FirstName,
            Account.MiddleName,
            Account.LastName,
            Account.CRM_Person__c,
            Account.INT_IsHasTombstone__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public List<Account> selectByIdent(String ident) {
        return (List<Account>) Database.query(
            newQueryFactory()
                .selectField('CRM_Person__r.INT_FirstName__c')
                .selectField('CRM_Person__r.INT_MiddleName__c')
                .selectField('CRM_Person__r.INT_LastName__c')
                .selectField('CRM_Person__r.INT_IsHasTombstone__c')
                .setCondition('INT_PersonIdent__c=:ident AND CRM_Person__r.INT_Confidential__c=\'UGRADERT\'')
                .toSOQL()
        );
    }

    public List<Account> selectByIdentIgnoreConfidential(String ident) {
        return (List<Account>) Database.query(
            newQueryFactory()
                .selectField('CRM_Person__r.INT_FirstName__c')
                .selectField('CRM_Person__r.INT_MiddleName__c')
                .selectField('CRM_Person__r.INT_LastName__c')
                .selectField('CRM_Person__r.INT_IsHasTombstone__c')
                .setCondition('INT_PersonIdent__c=:ident')
                .toSOQL()
        );
    }
}
