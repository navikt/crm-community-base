@isTest
public with sharing class RecordFilesControllerTest {

    @isTest
    static void testgetBaseDownloadUrl() {
        Test.startTest();
        String url = RecordFilesController.getBaseDownloadUrl();
        Test.stopTest();
        System.assertNotEquals(null, url, 'Could not create Salesforce base download URL');
    }
}
