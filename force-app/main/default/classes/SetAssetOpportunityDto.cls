/**
 * Created by caleb@argologic.com.au on 11/02/2021.
 */

public with sharing class SetAssetOpportunityDto
{
    @AuraEnabled
    public string OpportunityName;

    @AuraEnabled
    public Date OpportunityCloseDate;

    @AuraEnabled
    public string OpportunitySalesOwnerName;

    @AuraEnabled
    public Boolean IsWon;
}