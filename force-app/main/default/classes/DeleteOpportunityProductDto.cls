/**
 * Created by caleb@argologic.com.au on 2/11/2020.
 */

public with sharing class DeleteOpportunityProductDto
{
    @AuraEnabled
    public String OpportunityId {get; set;}

    @AuraEnabled
    public Boolean DoDeleteProduct {get; set;}

    @AuraEnabled
    public Boolean DoDeleteAsset {get; set;}

    @AuraEnabled
    public Boolean DoDeleteServicePlan {get; set;}
}