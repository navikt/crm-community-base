public with sharing class PersonAccountWrapper {
    public Id recordId { get; set; }
    public String firstName { get; set; }
    public String middleName { get; set; }
    public String lastName { get; set; }

    public PersonAccountWrapper() {
    }

    public PersonAccountWrapper(Account account) {
        this.recordId = account.PersonContactId;
        this.firstName = account.FirstName;
        this.middleName = account.MiddleName;
        this.lastName = account.LastName;
    }
}
