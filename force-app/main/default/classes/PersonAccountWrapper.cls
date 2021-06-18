public with sharing class PersonAccountWrapper {
    public Id recordId { get; set; }
    public String firstName { get; set; }
    public String middleName { get; set; }
    public String lastName { get; set; }

    public PersonAccountWrapper() {
    }

    public PersonAccountWrapper(Account account) {
        this.recordId = account.PersonContactId;
        this.firstName = account.CRM_Person__r.INT_FirstName__c;
        this.middleName = account.CRM_Person__r.INT_MiddleName__c;
        this.lastName = account.CRM_Person__r.INT_LastName__c;
    }
}
