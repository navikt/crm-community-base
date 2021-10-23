@isTest
public with sharing class RecordFilesControllerWithSharingTest {
    @testSetup
    static void setup() {
        Id PERSON_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account acc = new Account(FirstName = 'Person', LastName = 'Test', RecordTypeId = PERSON_ACCOUNT_RECORDTYPEID);
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
    static void getAllContentDocumentsTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<ContentDocument> contentDocuments = RecordFilesControllerWithSharing.getContentDocuments(acc.Id, true);
        Test.stopTest();
        System.assertEquals(1, contentDocuments.size(), 'Could not get ContentDocuments related to account');
    }

    @isTest
    static void getMyContentDocumentsTest() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'admin' LIMIT 1];

        User user = new User(
            Username = 'testuser@nav.no.test',
            LastName = 'testuser',
            Email = 'testuser@nav.no.test',
            Alias = 'testuser',
            CommunityNickname = 'testuser',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'no_NO',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'no',
            ProfileId = profile.Id
        );
        Account acc = [SELECT Id FROM Account LIMIT 1];
        System.runAs(user) {
            ContentVersion contentVersion = new ContentVersion(
                Title = 'title2',
                PathOnClient = 'pic2.jpg',
                VersionData = Blob.valueOf('test content 2'),
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

            Test.startTest();
            List<ContentDocument> contentDocuments = RecordFilesControllerWithSharing.getContentDocuments(
                acc.Id,
                false
            );
            Test.stopTest();
            System.assertEquals(1, contentDocuments.size(), 'Could not get ContentDocuments related to account');
        }
    }

    @isTest
    static void getBaseDownloadUrlTest() {
        Test.startTest();
        String url = RecordFilesControllerWithSharing.getBaseDownloadUrl();
        Test.stopTest();
        System.assertNotEquals(null, url, 'Could not create Salesforce base download URL');
    }

    @isTest
    static void deleteFilesOnRecordTest() {
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        List<String> files = new List<String>();
        for (ContentDocument cd : contentDocuments) {
            files.add(cd.Id);
        }

        Test.startTest();
        RecordFilesControllerWithSharing.deleteFilesOnRecord(files);
        Test.stopTest();
    }
}
