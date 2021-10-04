@isTest
public with sharing class RecordFilesControllerTest {
    @testSetup
    static void setup() {
        public static final Id PERSON_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId();
        Account acc = new Account(
            FirstName = 'Person',
            LastName = 'Test',
            RecordTypeId = PERSON_ACCOUNT_RECORDTYPEID
        );
        insert acc;
       
        ContentVersion contentVersion = HOT_TestDataFactory.createContentVersion();
        insert contentVersion;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocumentLink = HOT_TestDataFactory.createContentDocumentLink(
            acc.Id,
            documents[0].Id
        );
        insert contentDocumentLink;
    }

    @isTest
    static void testMethod1() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<ContentDocument> contentDocuments = HOT_RelatedFilesListController.getContentDocuments(acc.Id);
        System.assertEquals(1, contentDocuments.size(), 'Could not get ContentDocuments related to account');
    }
    
    @isTest
    static void testgetBaseDownloadUrl() {
        Test.startTest();
        String url = RecordFilesController.getBaseDownloadUrl();
        Test.stopTest();
        System.assertNotEquals(null, url, 'Could not create Salesforce base download URL');
    }
}
