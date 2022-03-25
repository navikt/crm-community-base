public with sharing class IdPortenSidController {
    public PageReference redirect() {
        Cookie stateCookie;
        Cookie nonceCookie;
        Cookie codeVerifierCookie;
        String code = apexpages.currentPage().getParameters().get('code');
    
        
        //initiate
        if (code == null) {
            IdPortenAuthUtil authUtil=new IdPortenAuthUtil();
            IdPortenAuthUtil.AuthResponse authResponse=authUtil.initiate();
            codeVerifierCookie = new Cookie('codeverifier',authResponse.codeVerifier,null,-1,true);
            stateCookie = new Cookie('state',authResponse.state,null,-1,true);
            nonceCookie = new Cookie('nonce',authResponse.nonce,null,-1,true);
	        ApexPages.currentPage().setCookies(new Cookie[]{codeVerifierCookie, stateCookie, nonceCookie });
            pageReference pg = new pageReference(authResponse.initiateUrl);
            return pg.setRedirect(true);
        }

         //handle callback
         String state = apexpages.currentPage().getParameters().get('state');
         
         codeVerifierCookie  = ApexPages.currentPage().getCookies().get('codeVerifier');
         String codeVerifierFromCookie=codeVerifierCookie.getValue();
         stateCookie = ApexPages.currentPage().getCookies().get('state');
         String stateFromCookie=stateCookie.getValue();
         nonceCookie  = ApexPages.currentPage().getCookies().get('nonce');
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
