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
                Account.CRM_Person__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public List<Account> selectByIdent(Set<String> idents) {
        return (List<Account>)
                Database.query(
                        newQueryFactory().
                                setCondition('INT_PersonIdent__c in :idents').
                                toSOQL());
    }
}