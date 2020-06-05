public with sharing class globalCommunityHeaderFooterController {
    @AuraEnabled
    public static Boolean isProd(){
        return UserInfo.getOrganizationId() == '00D2o000000aANV';
    }
}
