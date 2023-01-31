/**
 * Created by caleb on 17/10/2019.
 */

global with sharing class GetNidasuOpportunitiesResponseDto
{
    public void init()
    {

    }

    public GetNidasuOpportunitiesResponseDto()
    {
        init();
    }

    public List<NidasuOpportunityResourceDto> Data {get; set;}
}