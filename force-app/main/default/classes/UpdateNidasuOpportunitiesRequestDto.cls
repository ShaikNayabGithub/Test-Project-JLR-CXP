/**
 * Created by caleb on 17/10/2019.
 */

global with sharing class UpdateNidasuOpportunitiesRequestDto extends BaseRequestDto
{
    public void init()
    {
        if (Data == null)
        {
            Data = new List<UpdateNidasuOpportunitiesResourceDto>();
        }
    }

    public UpdateNidasuOpportunitiesRequestDto()
    {
        init();
    }

    public List<UpdateNidasuOpportunitiesResourceDto> Data {get; set;}
}