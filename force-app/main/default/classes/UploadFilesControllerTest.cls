@isTest
public with sharing class UploadFilesControllerTest {
    @TestSetup
    static void setup(){
        Id PERSON_ACCOUNT_RECORDTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId();
        Account acc = new Account(
            FirstName = 'Person',
            LastName = 'Test',
            RecordTypeId = PERSON_ACCOUNT_RECORDTYPEID
        );
        insert acc;
    }
    @isTest
    private static void uploadFileTest() {
        Map<String, String> files = new Map<String, String>();
        files.put('base64test', 'filename');

        UploadFilesController.uploadFile(files, acc.Id);
        List<ContentDocumentLink> file = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :acc.Id
        ];
        Boolean hasFile = file.size() > 0;
        System.assertEquals(true, hasFile, 'File was not uploaded');
    }
}
