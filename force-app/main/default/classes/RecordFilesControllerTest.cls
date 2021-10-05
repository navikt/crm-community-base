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

        ContentVersion contentVersion = new ContentVersion(
            Title = 'title',
            PathOnClient = 'pic.jpg',
            VersionData = Blob.valueOf('test content'),
            IsMajorVersion = true
        );
        insert contentVersion;
       
      
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = acc.Id;
        contentDocumentLink.ContentDocumentId = documents[0].Id;
        contentDocumentLink.shareType = 'V';
        contentDocumentLink.visibility = 'AllUsers';
        insert contentDocumentLink;
    }

    @isTest
    static void getContentDocumentsTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<ContentDocument> contentDocuments = RecordFilesController.getContentDocuments(acc.Id);
        Test.stopTest();
        System.assertEquals(1, contentDocuments.size(), 'Could not get ContentDocuments related to account');
    }
    
    @isTest
    static void getBaseDownloadUrlTest() {
        Test.startTest();
        String url = RecordFilesController.getBaseDownloadUrl();
        Test.stopTest();
        System.assertNotEquals(null, url, 'Could not create Salesforce base download URL');
    }
}
