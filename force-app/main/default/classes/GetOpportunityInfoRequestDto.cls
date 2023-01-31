/**
 * Created by caleb@argologic.com.au on 11/02/2020.
 */

public with sharing class GetOpportunityInfoRequestDto
{
    @AuraEnabled
    public string OpportunityId {get; set;}
}