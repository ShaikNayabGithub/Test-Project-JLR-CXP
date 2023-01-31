/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class GetMatchingAccountsRequestDto
{
    @AuraEnabled
    public string ContactNameFirst {get; set;}
    @AuraEnabled
    public string ContactNameLast {get; set;}
    @AuraEnabled
    public string AccountName {get; set;}
    @AuraEnabled
    public string ContactEmail {get; set;}
    @AuraEnabled
    public string ContactPhoneMobile {get; set;}
}