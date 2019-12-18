public with sharing class ContactWrapper {
    public Id contactId { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }

    public ContactWrapper() {

    }

    public ContactWrapper(Contact contact) {
        this.contactId = contact.Id;
        this.firstName = contact.FirstName;
        this.lastName = contact.LastName;
    }

    Public ContactWrapper(Account personAccount) {
        this.contactId = personAccount.PersonContactId;
        this.firstName = personAccount.FirstName;
        this.lastName = personAccount.LastName;
    }
}