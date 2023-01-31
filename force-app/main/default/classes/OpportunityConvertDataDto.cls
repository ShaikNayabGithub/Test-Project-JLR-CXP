/**
 * Created by caleb@argologic.com.au on 17/03/2021.
 */

public with sharing class OpportunityConvertDataDto
{
    @AuraEnabled
    public string leadFirstName;
    @AuraEnabled
    public string leadLastName;
    @AuraEnabled
    public string leadEmail;
    @AuraEnabled
    public string leadPhoneMobile;
    @AuraEnabled
    public string opportunityName;

    @AuraEnabled
    public List<MatchingPersonAccountAttributeDto> MatchingPersonAccounts {get; set;}
}