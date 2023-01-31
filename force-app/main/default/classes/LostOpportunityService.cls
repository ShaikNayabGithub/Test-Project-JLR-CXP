/**
 * Created by caleb on 19/09/2019.
 */

@RestResource(urlMapping='/v1/LostOpportunity/*')
global with sharing class LostOpportunityService
{
    @HttpGet
    global static GetLostOpportunitiesResponseDto getOpportunities()
    {
        try
        {
            GetLostOpportunitiesRequestDto request = new GetLostOpportunitiesRequestDto();
            return Op2maController.getLostOpportunities(request);
        }
        catch (Exception ex)
        {
            GetLostOpportunitiesResponseDto res = new GetLostOpportunitiesResponseDto();
            res.addError(ex);
            RestContext.response.statusCode = 400;

            ServiceErrorLogger.logError('GET /v1/LostOpportunity/', String.valueOf(Datetime.now()), ex);

            return res;
        }
    }

    @HttpPost
    global static UpdateLostOpportunitiesResponseDto updateLeads(UpdateLostOpportunitiesRequestDto request)
    {
        try
        {
            return Op2maController.updateLostOpportunities(request);
        }
        catch (Exception ex)
        {
            UpdateLostOpportunitiesResponseDto res = new UpdateLostOpportunitiesResponseDto();
            res.addError(ex);
            RestContext.response.statusCode = 400;

            ServiceErrorLogger.logError('POST /v1/LostOpportunity/', JSON.serialize(request), ex);

            return res;
        }
    }
}