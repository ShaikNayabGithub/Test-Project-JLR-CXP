/**
 * Created by caleb@argologic.com.au on 27/05/2020.
 */

@RestResource(UrlMapping='/v1/Opportunities/*')
global with sharing class OpportunityInboundService
{
    @HttpPost
    global static CreateOpportunityInboundResponseDto create(CreateOpportunityInboundRequestDto request)
    {
        try
        {
            CreateOpportunityInboundResponseDto res = OpportunityInboundController.create(request);
            RestContext.response.statusCode = 200;
            return res;
        }
        catch (Exception ex)
        {
            ServiceErrorLogger.logError('/v1/Opportunities/', JSON.serialize(request), ex);
            CreateOpportunityInboundResponseDto res = new CreateOpportunityInboundResponseDto();
            res.addError(ex);
            RestContext.response.statusCode = 400;
            return res;
        }
    }
}