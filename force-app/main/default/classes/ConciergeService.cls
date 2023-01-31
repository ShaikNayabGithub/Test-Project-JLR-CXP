/**
 * Created by caleb on 18/09/2019.
 */

@RestResource(urlMapping='/v1/Concierge/*')
global with sharing class ConciergeService
{
    @HttpGet
    global static GetLeadsResponseDto getLeads()
    {
        GetLeadsRequestDto request = new GetLeadsRequestDto();
        return Op2maController.getConciergeLeads(request);
    }

    @HttpPost
    global static UpdateConciergeLeadsResponseDto updateLeads(UpdateConciergeLeadsRequestDto request)
    {
        return Op2maController.updateConciergeLeads(request);
    }
}