public with sharing class IdPortenAuthUtil {
    private static final Integer SESSION_DURATION_IN_MINUTES = 24;
    private Map<String, String> authProviderConfiguration;
    private final LoggerUtility logger;

    public IdPortenAuthUtil() {
        authProviderConfiguration = getAuthProviderConfiguration();
        logger = new LoggerUtility(
            CRM_ApplicationDomain.Domain.PLATFORCE,
            'IdPorten'
        );
    }

    public AuthResponse initiate(String pageName) {
        AuthResponse response = new AuthResponse();
        response.state = PKCEOAuthHelper.generateState();
        response.codeVerifier = PKCEOAuthHelper.generateCodeVerifier();
        String codeChallenge = PKCEOAuthHelper.getCodeChallenge(
            response.codeVerifier
        );
        response.nonce = PKCEOAuthHelper.generateNonce();
        response.redirectUrl = getRedirectUrl(pageName);
        String authorizeEndpointUrl = authProviderConfiguration.get(
            'AuthorizeEndpointUrl'
        );
        String consumerKey = authProviderConfiguration.get('ConsumerKey');
        String acrValues = authProviderConfiguration.get('AcrValues');
        String consumerSecret = authProviderConfiguration.get('ConsumerSecret');
        String scope = 'openid';
        response.initiateUrl =
            authorizeEndpointUrl +
            '?client_id=' +
            consumerKey +
            '&acr_values=' +
            acrValues +
            '&scope=' +
            scope +
            '&redirect_uri=' +
            response.redirectUrl +
            '&response_type=code&state=' +
            response.state +
            '&code_challenge=' +
            codeChallenge +
            '&code_challenge_method=S256&ui_locales=nb&nonce=' +
            response.nonce;
        return response;
    }

    public void storeSid(String sid, Id userId) {
        if (String.isNotBlank(sid)) {
            IdPortenCache__c cache = new IdPortenCache__c();
            cache.Name = sid;
            cache.UserId__c = userId;
            cache.ExpirationTime__c = DateTime.Now()
                .addMinutes(SESSION_DURATION_IN_MINUTES);
            Database.SaveResult result = Database.insert(cache, false);
            if (!result.isSuccess()) {
                logger.logMessage(
                    LoggerUtility.LogLevel.ERROR,
                    '',
                    '',
                    'Kunne ikke lagre SID i cache: ',
                    this.databaseErrorsToString(result.getErrors()),
                    null
                );
            }
        } else {
            logger.error('ID-token er blank', null);
        }
        logger.publishSynch();
    }

    public TokenResponse getSidFromIdToken(
        String code,
        String codeVerifier,
        String nonce,
        String pageName
    ) {
        String consumerKey = authProviderConfiguration.get('ConsumerKey');
        String consumerSecret = authProviderConfiguration.get('ConsumerSecret');
        String tokenEndpointUrl = authProviderConfiguration.get(
            'TokenEndpointUrl'
        );
        String encodedRedirectUrl = EncodingUtil.urlEncode(
            getRedirectUrl(pageName),
            'UTF-8'
        );

        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenEndpointUrl);
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody(
            'grant_type=authorization_code&redirect_uri=' +
                encodedRedirectUrl +
                '&code=' +
                code +
                '&client_id=' +
                consumerKey +
                '&client_secret=' +
                consumerSecret +
                '&code_verifier=' +
                codeVerifier
        );

        HTTPResponse res = new Http().send(req);

        if (res.getStatusCode() != 200) {
            logger.logMessage(
                LoggerUtility.LogLevel.ERROR,
                '',
                '',
                'Kunne ikke hente id token',
                res.getBody(),
                null
            );
            logger.publishSynch();
            return null;
        }

        String idToken = getTokenValueFromResponse(res.getBody(), 'id_token');
        JWTClaims decodedIdToken = decodeIdToken(idToken);

        if (decodedIdToken.nonce == null || decodedIdToken.nonce != nonce) {
            logger.logMessage(
                LoggerUtility.LogLevel.ERROR,
                '',
                '',
                'Nonce samsvarer ikke.',
                '',
                null
            );
            logger.publishSynch();
            return null;
        }
        TokenResponse resp = new TokenResponse();
        resp.sid = decodedIdToken.sid;
        return resp;
    }

    public String getRedirectUrl(String pageName) {
        if (Test.isRunningTest()) {
            return 'https://callback';
        }
        String redirectUrl = Network.getLoginUrl(Network.getNetworkId());
        redirectUrl = redirectUrl.replace('/login', '/' + pageName);
        return redirectUrl;
    }

    private Map<string, string> getAuthProviderConfiguration() {
        Map<string, string> authProviderConfiguration = new Map<String, String>();

        if (Test.isRunningTest()) {
            authProviderConfiguration.put('AcrValues', 'arc');
            authProviderConfiguration.put(
                'AuthorizeEndpointUrl',
                'https://auth'
            );
            authProviderConfiguration.put('ConsumerKey', 'key');
            authProviderConfiguration.put('ConsumerSecret', 'secret');
            authProviderConfiguration.put('TokenEndpointUrl', 'https://token');
            authProviderConfiguration.put(
                'TokenInfoEndpointUrl',
                'https://tokenInfo'
            );
            return authProviderConfiguration;
        }

        ID_porten__mdt mdt = [
            SELECT
                AcrValues__c,
                AuthorizeEndpointUrl__c,
                ConsumerKey__c,
                ConsumerSecret__c,
                TokenEndpointUrl__c
            FROM ID_porten__mdt
            WHERE DeveloperName = 'IdPorten'
        ];
        // TokenInfoEndpointUrl__c
        authProviderConfiguration.put('AcrValues', mdt.AcrValues__c);
        authProviderConfiguration.put(
            'AuthorizeEndpointUrl',
            mdt.AuthorizeEndpointUrl__c
        );
        authProviderConfiguration.put('ConsumerKey', mdt.ConsumerKey__c);
        authProviderConfiguration.put('ConsumerSecret', mdt.ConsumerSecret__c);
        authProviderConfiguration.put(
            'TokenEndpointUrl',
            mdt.TokenEndpointUrl__c
        );
        // authProviderConfiguration.put('TokenInfoEndpointUrl', mdt.TokenInfoEndpointUrl__c);
        return authProviderConfiguration;
    }

    public void extendSession() {
        List<IdPortenCache__c> listOfCache = [
            SELECT Id, ExpirationTime__c
            FROM IdPortenCache__c
            WHERE UserId__c = :UserInfo.getUserId()
        ];
        for (IdPortenCache__c cache : listOfCache) {
            cache.ExpirationTime__c = DateTime.Now()
                .addMinutes(SESSION_DURATION_IN_MINUTES);
        }

        List<Database.SaveResult> results = Database.update(listOfCache, false);
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                logger.logMessage(
                    LoggerUtility.LogLevel.ERROR,
                    '',
                    '',
                    'Kunne ikke oppdatere IdPortenCache',
                    this.databaseErrorsToString(result.getErrors()),
                    null
                );
            }
        }

        logger.publishSynch();
    }

    private static String getTokenValueFromResponse(
        String response,
        String token
    ) {
        String tokenValue = '';
        try {
            JSONParser parser = JSON.createParser(response);

            while (parser.nextToken() != null) {
                if (parser.getText() == token) {
                    parser.nextToken();
                    tokenValue = parser.getText();
                }
            }
        } catch (Exception e) {
            logger.logMessage(
                LoggerUtility.LogLevel.ERROR,
                '',
                '',
                e.getMessage(),
                e.getStackTraceString(),
                null
            );
        }
        logger.publishSynch();
        return tokenValue;
    }

    private static JWTClaims decodeIdToken(String encodedJWT) {
        try {
            Integer headerLength = encodedJWT.indexOf('.');
            Integer claimsLength = encodedJWT.lastIndexOf('.');
            String jwtClaims = encodedJWT.mid(
                headerLength + 1,
                claimsLength - headerLength - 1
            );

            JWTClaims claimsDeserialized = (JWTClaims) Json.deserialize(
                EncodingUtil.base64Decode(jwtClaims).toString(),
                JWTClaims.class
            );
            return claimsDeserialized;
        } catch (Exception e) {
            logger.logMessage(
                LoggerUtility.LogLevel.ERROR,
                '',
                '',
                e.getMessage(),
                e.getStackTraceString(),
                null
            );
            logger.publishSynch();
        }
        return new JWTClaims();
    }

    public class AuthResponse {
        public String state { get; set; }
        public String codeVerifier { get; set; }
        public String nonce { get; set; }
        public String redirectUrl { get; set; }
        public String initiateUrl { get; set; }
    }

    private class JWTClaims {
        String sid;
        String nonce;
    }

    public class TokenResponse {
        public String sid { get; set; }
    }

    private String databaseErrorsToString(List<Database.Error> errors) {
        String errorMessages = '';
        for (Database.Error error : errors) {
            errorMessages += error.getMessage() + ';\n';
        }
        return errorMessages;
    }
}
