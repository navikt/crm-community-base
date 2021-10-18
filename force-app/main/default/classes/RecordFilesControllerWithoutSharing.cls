public without sharing class RecordFilesControllerWithoutSharing {
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

    @AuraEnabled
    public static void deleteFilesOnRecord(List<String> files) {
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Id IN :files];
        deleteFiles(contentDocuments);
    }

    private static void deleteFiles(List<ContentDocument> contentDocuments) {
        try {
            delete contentDocuments;
        } catch (DMLException e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
}
