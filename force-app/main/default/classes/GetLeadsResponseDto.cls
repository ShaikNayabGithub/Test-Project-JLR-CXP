/**
 * Created by caleb on 18/09/2019.
 */

global with sharing class GetLeadsResponseDto
{
    @AuraEnabled
    public List<LeadConciergeDataDto> Data;
}