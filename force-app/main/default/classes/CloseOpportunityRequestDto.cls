/**
 * Created by caleb@argologic.com.au on 5/02/2020.
 */

public with sharing class CloseOpportunityRequestDto
{
    @AuraEnabled
    public String OpportunityId { get; set; }

    @AuraEnabled
    public String OpportunityStage { get; set; }

    @AuraEnabled
    public String LostReason { get; set; }

    @AuraEnabled
    public String LostDescription { get; set; }

    @AuraEnabled
    public String PlanedHandoverDate { get; set; }

    @AuraEnabled
    public String OpportunityEmail {get; set;}
}