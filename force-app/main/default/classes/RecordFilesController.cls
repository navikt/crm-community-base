public with sharing class RecordFilesController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getContentDocuments(String recordId) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];
        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
        }
        List<ContentDocument> contentDocuments = [
            SELECT Id, FileType, CreatedDate, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds AND ContentAssetId = NULL
        ];
        return contentDocuments;
    }

    @AuraEnabled(cacheable=true)
    public static String getBaseDownloadUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/';
    }
}
