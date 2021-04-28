public inherited sharing class UsersSelector_Community extends ApplicationSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ User.Id, User.FirstName, User.LastName, User.MiddleName, User.ProfileId, User.AccountId };
    }

    public Schema.SObjectType getSObjectType() {
        return User.sObjectType;
    }

    public List<User> selectByAccountIdent(Set<String> idents) {
        return (List<User>) Database.query(
            newQueryFactory().setCondition('Account.INT_PersonIdent__c in: idents').toSOQL()
        );
    }

    public List<User> selectByAccountId(Set<Id> accountIds) {
        return (List<User>) Database.query(
            newQueryFactory().setCondition('AccountId in: accountIds').toSOQL()
        );
    }
}
