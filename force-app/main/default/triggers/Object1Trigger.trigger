trigger Object1Trigger on  Object1__c (after update) {

    Object3__c obj3=new Object3__c(Name='Test');
    insert obj3;
}