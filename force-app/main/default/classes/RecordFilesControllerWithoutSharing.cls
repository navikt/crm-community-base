public without sharing class RecordFilesControllerWithoutSharing {
    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getContentDocuments(
        String recordId,
        Boolean isGetAll
    ) {
        if (recordId == null) {
            return new List<ContentDocument>{};
        }
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

        Map<Id, ContentDocument> ducumentsLinkedToRecordMap = new Map<Id, ContentDocument>(
            [
                SELECT Id, FileType, CreatedDate, Title
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds AND ContentAssetId = NULL
            ]
        );

        List<UserRecordAccess> documentsWithAccess = [
            SELECT RecordId
            FROM UserRecordAccess
            WHERE
                UserId = :UserInfo.getUserId()
                AND RecordId IN :ducumentsLinkedToRecordMap.keySet()
                AND HasReadAccess = TRUE
        ];

        List<ContentDocument> contentDocumentsWithAccess = new List<ContentDocument>();
        for (UserRecordAccess documentWithAccess : documentsWithAccess) {
            contentDocumentsWithAccess.add(
                ducumentsLinkedToRecordMap.get(documentWithAccess.RecordId)
            );
        }

        return contentDocumentsWithAccess;
    }

    @AuraEnabled
    public static List<Id> getOnlyMyContentDocuments(
        List<Id> contentDocumentIds
    ) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE
                LinkedEntityId = :UserInfo.getUserId()
                AND ContentDocumentId IN :contentDocumentIds
        ];
        List<Id> filteredContentDocumentIds = new List<Id>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
            filteredContentDocumentIds.add(
                contentDocumentLink.ContentDocumentId
            );
        }
        return filteredContentDocumentIds;
    }

    @AuraEnabled(cacheable=true)
    public static String getBaseDownloadUrl() {
        return Site.getBaseUrl() + '/sfc/servlet.shepherd/document/download/';
    }

    @AuraEnabled
    public static void deleteFilesOnRecord(List<String> files) {
        List<ContentDocument> contentDocuments = [
            SELECT Id
            FROM ContentDocument
            WHERE Id IN :files
        ];
        deleteFiles(contentDocuments);
    }

    private static void deleteFiles(List<ContentDocument> contentDocuments) {
        Map<Id, ContentDocument> ducumentsMap = new Map<Id, ContentDocument>(
            contentDocuments
        );
        List<UserRecordAccess> documentsWithAccess = [
            SELECT RecordId
            FROM UserRecordAccess
            WHERE
                UserId = :UserInfo.getUserId()
                AND RecordId IN :ducumentsMap.keySet()
                AND HasDeleteAccess = TRUE
        ];

        List<ContentDocument> contentDocumentsWithAccess = new List<ContentDocument>();
        for (UserRecordAccess documentWithAccess : documentsWithAccess) {
            contentDocumentsWithAccess.add(
                ducumentsMap.get(documentWithAccess.RecordId)
            );
        }
        try {
            delete contentDocumentsWithAccess;
        } catch (DMLException e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
}
