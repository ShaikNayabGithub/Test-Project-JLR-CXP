/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class GetMatchingPersonAccountsRequestDto
{
    @AuraEnabled
    public string PersonNameFirst {get; set;}
    @AuraEnabled
    public string PersonNameLast {get; set;}
    @AuraEnabled
    public string PersonEmail {get; set;}
    @AuraEnabled
    public string PersonPhoneMobile {get; set;}
    @AuraEnabled
    public string OwnerAccountId {get; set;}
}