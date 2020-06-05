public with sharing class GlobalCommunityHeaderFooterController {
    @AuraEnabled
    public static Boolean isProd(){
        return UserInfo.getOrganizationId() == '00D2o000000aANV';
    }
}
