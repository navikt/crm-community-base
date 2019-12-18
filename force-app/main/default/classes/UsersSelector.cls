public inherited sharing class UsersSelector extends ApplicationSelector {

    public List<User> selectByAccountIdent(Set<String> idents){
        return (List<User>)
                Database.query(
                        newQueryFactory()
                                .setCondition('Account.INT_Ident__c in: idents')
                                .toSOQL());
    }
}