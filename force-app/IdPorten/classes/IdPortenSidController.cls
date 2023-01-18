public with sharing class IdPortenSidController {
    public PageReference redirect() {
        Cookie stateCookie;
        Cookie nonceCookie;
        Cookie codeVerifierCookie;
        Cookie retUrlCookie;
        String code = apexpages.currentPage().getParameters().get('code');
        String retUrl=ApexPages.currentPage().getParameters().get('retURL');
        //stop login flow when mobile app
        String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent!=null && userAgent.contains('SalesforceMobileSDK')){
            return Auth.SessionManagement.finishLoginFlow(retUrl);
        }
        
        //initiate
        if (code == null) {
            IdPortenAuthUtil authUtil=new IdPortenAuthUtil();
            IdPortenAuthUtil.AuthResponse authResponse=authUtil.initiate();
            codeVerifierCookie = new Cookie('codeverifier',authResponse.codeVerifier,null,1800,true);
            stateCookie = new Cookie('state',authResponse.state,null,1800,true);
            nonceCookie = new Cookie('nonce',authResponse.nonce,null,1800,true);
	        
            //cache retUrl to be used in finishLoginFlow
            String relativeRetUrl=getRelativeRetUrl(retUrl);
            retUrlCookie = new Cookie('retUrl',relativeRetUrl,null,1800,true);
	        
            ApexPages.currentPage().setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie, retUrlCookie });
            pageReference pg = new pageReference(authResponse.initiateUrl);
            return pg.setRedirect(true);
        }

         //handle callback
         String state = apexpages.currentPage().getParameters().get('state');
         
         codeVerifierCookie  = ApexPages.currentPage().getCookies().get('codeVerifier');
         stateCookie = ApexPages.currentPage().getCookies().get('state');
         nonceCookie  = ApexPages.currentPage().getCookies().get('nonce');
         
         if(codeVerifierCookie ==null || stateCookie==null || nonceCookie==null){
            LoggerUtility logger = new LoggerUtility();
            logger.error('Cookies er ikke satt',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }
        
         String codeVerifierFromCookie=codeVerifierCookie.getValue();
         String stateFromCookie=stateCookie.getValue();
         String nonceFromCookie=nonceCookie.getValue();

        if(state==null || state!=stateFromCookie){
            LoggerUtility logger = new LoggerUtility();
            logger.error('State samsvarer ikke',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        if(nonceFromCookie==null){
            LoggerUtility logger = new LoggerUtility();
            logger.error('Nonce er blank',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        if(codeVerifierFromCookie==null){
            LoggerUtility logger = new LoggerUtility();
            logger.error('Code verifier er blank',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return finishLoginFlow();
        }

        IdPortenAuthUtil authUtil=new IdPortenAuthUtil();
        String sid=authUtil.getSidFromIdToken(code,codeVerifierFromCookie,nonceFromCookie);
        Id userId=UserInfo.getUserId();
        authUtil.storeSid(sid,userId);
        return finishLoginFlow();
    }

    private static PageReference finishLoginFlow(){
        List<String> communitiesUsingNewDecorator=new List<String>{'0DB2o000000Ug6i'};
        
        Cookie retUrlCookie = ApexPages.currentPage().getCookies().get('retUrl');
        if(retUrlCookie==null){
            LoggerUtility logger = new LoggerUtility();
            logger.error('Kunne ikke hente ret ur fra cookie',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return Auth.SessionManagement.finishLoginFlow();
        }
        String retUrl=retUrlCookie.getValue(); 

        if(retUrl!=null && communitiesUsingNewDecorator.contains(Network.getNetworkId())){
            //redirect to loginservice to be able to use new decorator
            return Auth.SessionManagement.finishLoginFlow('/apex/NavLoginService?retUrl=' + retUrl);
        }

        if(retUrl!=null){
            return Auth.SessionManagement.finishLoginFlow(retUrl);
        }
        return Auth.SessionManagement.finishLoginFlow();
    }

    private static String getRelativeRetUrl(String retUrl){
        String communityBaseUrl=Network.getLoginUrl(Network.getNetworkId());
        if(Test.isRunningTest()){
           communityBaseUrl='https://test-comunity.com/login';
        }
        communityBaseUrl=communityBaseUrl.replace('/login', '');
        //remove base url from retUrl
        if(retUrl!=null){
           retUrl=retUrl.replace(communityBaseUrl,'');
           //remove spaces
           retUrl=retUrl.replaceAll(' ','%20');
        }
        return retUrl;
    }
}
