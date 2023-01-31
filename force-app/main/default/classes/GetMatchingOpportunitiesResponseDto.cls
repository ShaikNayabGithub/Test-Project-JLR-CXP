/**
 * Created by caleb@argologic.com.au on 2/03/2020.
 */

public with sharing class GetMatchingOpportunitiesResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public List<MatchingOpportunityDto> Opportunities {get; set;}
}