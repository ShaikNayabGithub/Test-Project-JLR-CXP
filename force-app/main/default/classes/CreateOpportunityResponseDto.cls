/**
 * Created by caleb on 16/10/2019.
 */

public with sharing class CreateOpportunityResponseDto extends BaseResponseDto
{
    @AuraEnabled
    public String OpportunityId {get; set;}
    List<CreateOpportunityAttributeDto> Attributes {get; set;}
}