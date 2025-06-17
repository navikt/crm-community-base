/**
 * @description Custom exception for IdPorten errors.
 *
 * @author Tor Håkon Sigurdsen
 * @since 2025-jun
 */
public without sharing class IdPortenException extends Exception {
    // Added in order to avoid no test coverage even if the exception class is used.
    // This is probably a bug in the Salesforce platform.
    private Boolean IdPortenException = true;
}
