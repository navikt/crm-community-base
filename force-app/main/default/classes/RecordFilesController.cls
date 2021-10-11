public without sharing class RecordFilesController {
    @AuraEnabled(cacheable=true)
    public static String getBaseDownloadUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/';
    }

    public static String recordId;
    public static Boolean isGetAll;
    public static Boolean isWithoutSharing;

    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getContentDocuments(
        String recordId,
        Boolean isGetAll,
        Boolean isWithoutSharing
    ) {
        RecordFilesControllerInherit instance = new RecordFilesControllerInherit();
        instance.recordId = recordId;
        instance.isGetAll = isGetAll;
        if (isWithoutSharing) {
            RecordFilesControllerWithSharing sharingInstance = new RecordFilesControllerWithSharing();
            return sharingInstance.getContentDocuments(instance);
        }
        RecordFilesControllerWithoutSharing withoutSharingInstance = new RecordFilesControllerWithoutSharing();
        return withoutSharingInstance.getContentDocuments(instance);
    }

    public with sharing class RecordFilesControllerWithSharing {
        public List<ContentDocument> getContentDocuments(RecordFilesControllerInherit instance) {
            return instance.getContentDocuments();
        }
    }
    public without sharing class RecordFilesControllerWithoutSharing {
        public List<ContentDocument> getContentDocuments(RecordFilesControllerInherit instance) {
            return instance.getContentDocuments();
        }
    }

    public class RecordFilesControllerInherit {
        public String recordId;
        public Boolean isGetAll;

        public List<ContentDocument> getContentDocuments() {
            List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :this.recordId
            ];

            List<Id> contentDocumentIds = new List<Id>();
            for (ContentDocumentLink contentDocumentLink : contentDocumentLinks) {
                contentDocumentIds.add(contentDocumentLink.ContentDocumentId);
            }

            if (!this.isGetAll) {
                contentDocumentIds = getOnlyMyContentDocuments(contentDocumentIds);
            }

            List<ContentDocument> contentDocuments = [
                SELECT Id, FileType, CreatedDate, Title
                FROM ContentDocument
                WHERE Id IN :contentDocumentIds AND ContentAssetId = NULL
            ];
            return contentDocuments;
        }

        public List<Id> getOnlyMyContentDocuments(List<Id> contentDocumentIds) {
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
    }
}
