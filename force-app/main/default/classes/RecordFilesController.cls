public with sharing class RecordFilesController {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getContentDocuments(String recordId, Boolean isGetAll) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];

        List<Id> contentDocumentIds = new List<Id>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
        }

        if (!isGetAll) {
            contentDocumentIds = getOnlyMyContentDocuments(contentDocumentIds);
        }

        List<ContentDocument> contentDocuments = [
            SELECT Id, FileType, CreatedDate, Title
            FROM ContentDocument
            WHERE Id IN :contentDocumentIds AND ContentAssetId = NULL
        ];
        return contentDocuments;
    }

    public static List<Id> getOnlyMyContentDocuments(List<Id> contentDocumentIds) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :UserInfo.getUserId() AND ContentDocumentId IN :contentDocumentIds
        ];
        List<Id> filteredContentDocumentIds = new List<Id>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            filteredContentDocumentIds.add(contentDocumentLink.ContentDocumentId);
        }
        return filteredContentDocumentIds;
    }

    @AuraEnabled(cacheable=true)
    public static String getBaseDownloadUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/';
    }
}
