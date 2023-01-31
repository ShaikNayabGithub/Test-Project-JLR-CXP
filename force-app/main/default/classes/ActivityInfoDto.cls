/**
 * Created by caleb@argologic.com.au on 12/08/2020.
 */

public with sharing class ActivityInfoDto
{
    @AuraEnabled
    public string WhatType {get; set;}

    @AuraEnabled
    public string Id {get; set;}

    @AuraEnabled
    public Boolean OpportunityIsClosed {get; set;}

    @AuraEnabled
    public String OpportunityContactEmail {get; set;}

    @AuraEnabled
    public String WhoId {get; set;}

}