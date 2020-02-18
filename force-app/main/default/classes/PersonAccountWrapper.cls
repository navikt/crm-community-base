public with sharing class PersonAccountWrapper {
    public Id recordId { get; set; }
    public String municipality { get; set; }
    public String firstName {get;set;}
    public String lastName {get;set;}

    public PersonAccountWrapper(){

    }

    public PersonAccountWrapper (Account account){
        this.recordId=account.PersonContactId;
        this.municipality=account.INT_MunicipalityNumber__c;
        this.firstName=account.FirstName;
        this.lastName=account.LastName;
    }
}