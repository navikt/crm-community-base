public with sharing class IdPortenSidController {
    public PageReference redirect() {
        Cookie codeVerifierCookie;
        String code = apexpages.currentPage().getParameters().get('code');
        //initiate
        if (code == null) {
            String codeVerifierValue=PKCEOAuthHelper.generateCodeVerifier();
            codeVerifierCookie = new Cookie('codeverifier',codeVerifierValue,null,-1,true);
	        ApexPages.currentPage().setCookies(new Cookie[]{codeVerifierCookie });
            
            system.debug('a');
            String initiateUrl = 'https://sandbox-business-ability-1275-17fbcd409ea.cs189.force.com/innboks/IdPortenSid?code=123';
            pageReference pg = new pageReference(initiateUrl);
            return pg.setRedirect(true);
        }

        //handle callback
        system.debug('b');
        codeVerifierCookie  = ApexPages.currentPage().getCookies().get('codeVerifier');
        String codeVerifierValueFromCookie=codeVerifierCookie.getValue();
        system.debug(codeVerifierValueFromCookie);
        return Auth.SessionManagement.finishLoginFlow();
    }
}
