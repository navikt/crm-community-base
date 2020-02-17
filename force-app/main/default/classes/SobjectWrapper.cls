public with sharing class SobjectWrapper {
    public Id recordId { get; set; }
    public String municipality { get; set; }
    public String firstName {get;set;}
    public String lastName {get;set;}

    public SobjectWrapper() {
    }

    public SobjectWrapper(CustomOpportunity__c opportunity){
        this.recordId=opportunity.Id;
        this.municipality=opportunity.INT_MunicipalityNumber__c;
    }

    public SobjectWrapper(Account account){
        this.recordId=account.PersonContactId;
        this.municipality=account.INT_MunicipalityNumber__c;
        this.firstName=account.FirstName;
        this.lastName=account.LastName;
    }

    public static List<SobjectWrapper> getFromCustomOpportunities(List<CustomOpportunity__c> customOpportunities){
        List<SobjectWrapper> wrappers = new List<SobjectWrapper>();
        for(CustomOpportunity__c opportunity:customOpportunities){
            wrappers.add(new SobjectWrapper(opportunity));
        }
        return wrappers;
    }
}