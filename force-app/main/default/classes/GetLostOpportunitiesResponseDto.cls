/**
 * Created by caleb on 18/09/2019.
 */

global with sharing class GetLostOpportunitiesResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public List<OpportunityLostDataDto> Data {get; set;}
}