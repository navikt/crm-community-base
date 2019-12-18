public inherited sharing class PersonAccountsSelector extends ApplicationSelector{

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Account.Id,
                Account.Name,
                Account.INT_Ident__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Account.sObjectType;
    }

    public List<Account> selectByIdent(Set<String> idents) {
        return (List<Account>)
                Database.query(
                        newQueryFactory().
                                setCondition('INT_Ident__c in :idents').
                                toSOQL());
    }
}