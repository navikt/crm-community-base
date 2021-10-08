public with sharing class UploadFilesController {
    @AuraEnabled
    public static void uploadFile(Map<String, String> files, String recordId) {
        List<ContentVersion> cvList = new List<ContentVersion>();
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for (String base64 : files.keySet()) {
            cvList.add(createContentVersion(base64, files.get(base64)));
        }
        insertContentVersions(cvList);
        for (ContentVersion cv : cvList) {
            cdlList.add(createContentDocumentLink(cv.Id, recordId));
        }
        insertContentDocumentLinks(cdlList);
    }

    private static void insertContentDocumentLinks(List<ContentDocumentLink> cdlList) {
        try {
            insert cdlList;
        } catch (DMLException e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }

    private static void insertContentVersions(List<ContentVersion> cvList) {
        try {
            insert cvList;
        } catch (DMLException e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }

    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        return cv;
    }

    private static ContentDocumentLink createContentDocumentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) {
            return null;
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        ContentVersion cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId];
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
        cdl.Visibility = 'AllUsers';
        return cdl;
    }
}
