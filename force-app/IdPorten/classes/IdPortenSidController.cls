public with sharing class IdPortenSidController {
    public PageReference redirect() {
        Cookie stateCookie;
        Cookie nonceCookie;
        Cookie codeVerifierCookie;
        String code = apexpages.currentPage().getParameters().get('code');
        
        //Handling potential retUrl if the redirect should not go directly to experience home page
        String retUrl = apexpages.currentPage().getParameters().get('retURL');
        retUrl = String.isNotBlank(retUrl) ? EncodingUtil.base64Decode(retUrl).toString() : retUrl;
        
        //stop login flow when mobile app
        String userAgent =ApexPages.currentPage().getHeaders().get('USER-AGENT');
        if(userAgent!=null && userAgent.contains('SalesforceMobileSDK')){
            return String.isNotBlank(retUrl) ? Auth.SessionManagement.finishLoginFlow(retUrl) : Auth.SessionManagement.finishLoginFlow();
        }
        
        //initiate
        if (code == null) {
            IdPortenAuthUtil authUtil=new IdPortenAuthUtil();
            IdPortenAuthUtil.AuthResponse authResponse=authUtil.initiate();
            codeVerifierCookie = new Cookie('codeverifier',authResponse.codeVerifier,null,1800,true);
            stateCookie = new Cookie('state',authResponse.state,null,1800,true);
            nonceCookie = new Cookie('nonce',authResponse.nonce,null,1800,true);
	        ApexPages.currentPage().setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie });
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
            return Auth.SessionManagement.finishLoginFlow();
        }
        
         String codeVerifierFromCookie=codeVerifierCookie.getValue();
         String stateFromCookie=stateCookie.getValue();
         String nonceFromCookie=nonceCookie.getValue();

        if(state==null || state!=stateFromCookie){
            LoggerUtility logger = new LoggerUtility();
            logger.error('State samsvarer ikke',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return Auth.SessionManagement.finishLoginFlow();
        }

        if(nonceFromCookie==null){
            LoggerUtility logger = new LoggerUtility();
            logger.error('Nonce er blank',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return Auth.SessionManagement.finishLoginFlow();
        }

        if(codeVerifierFromCookie==null){
            LoggerUtility logger = new LoggerUtility();
            logger.error('Code verifier er blank',null, CRM_ApplicationDomain.Domain.NKS);
            logger.publishSynch();
            return Auth.SessionManagement.finishLoginFlow();
        }

        IdPortenAuthUtil authUtil=new IdPortenAuthUtil();
        String sid=authUtil.getSidFromIdToken(code,codeVerifierFromCookie,nonceFromCookie);
        Id userId=UserInfo.getUserId();
        authUtil.storeSid(sid,userId);
        return Auth.SessionManagement.finishLoginFlow();
    }
}
