public with sharing class RecordFilesControllerWithSharing {
    public static List<ContentDocument> getContentDocuments(String recordId, Boolean isGetAll) {
        return RecordFilesService.getContentDocuments(recordId, isGetAll);
    }
}
