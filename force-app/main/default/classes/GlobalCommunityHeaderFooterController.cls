public with sharing class GlobalCommunityHeaderFooterController {
    @AuraEnabled(cacheable=true)
    public static Boolean isProd() {
        return UserInfo.getOrganizationId() == '00D2o000000aANVEA2';
    }
}
