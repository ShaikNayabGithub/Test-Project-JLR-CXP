/**
 * Created by caleb@argologic.com.au on 7/04/2021.
 */

public with sharing class ConvertLeadDto
{
    @AuraEnabled
    public string leadId {get; set;}
    @AuraEnabled
    public string accountId {get; set;}
    @AuraEnabled
    public string opportunityId {get; set;}
    @AuraEnabled
    public string opportunityName {get; set;}
    @AuraEnabled
    public string accountFirstName {get; set;}
    @AuraEnabled
    public string accountLastName {get; set;}
    @AuraEnabled
    public string accountEmail {get; set;}
    @AuraEnabled
    public string accountMobile {get; set;}
}