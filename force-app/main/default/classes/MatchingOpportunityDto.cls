/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class MatchingOpportunityDto
{
    @AuraEnabled
    public String Id {get; set;}
    @AuraEnabled
    public String OpportunityName {get; set;}
    @AuraEnabled
    public String VehicleBrand {get; set;}
    @AuraEnabled
    public String VehicleModel {get; set;}
    @AuraEnabled
    public String PrimaryContact {get; set;}
    @AuraEnabled
    public String Owner {get; set;}
    @AuraEnabled
    public Date CreatedDate {get; set;}
}