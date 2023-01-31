/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class GetMatchingOpportunitiesRequestDto
{
    @AuraEnabled
    public string ContactId {get; set;}
}