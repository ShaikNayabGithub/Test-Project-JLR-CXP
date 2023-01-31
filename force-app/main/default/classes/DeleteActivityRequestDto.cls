/**
 * Created by caleb@argologic.com.au on 24/06/2020.
 */

public with sharing class DeleteActivityRequestDto
{
    @AuraEnabled
    public string ActivityId {get; set;}

    @AuraEnabled
    public string RelatedMilestone {get; set;}

    @AuraEnabled
    public string OpportunityId {get; set;}
}