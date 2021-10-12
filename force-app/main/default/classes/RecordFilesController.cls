public with sharing class RecordFilesController {
    @AuraEnabled(cacheable=true)
    public static String getBaseDownloadUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/';
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentDocument> getContentDocuments(
        String recordId,
        Boolean isGetAll,
        Boolean isWithoutSharing
    ) {
        if (isWithoutSharing) {
            return RecordFilesControllerWithoutSharing.getContentDocuments(recordId, isGetAll);
        }
        return RecordFilesControllerWithSharing.getContentDocuments(recordId, isGetAll);
    }
}
