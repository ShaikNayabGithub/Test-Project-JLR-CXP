/**
 * Created by caleb@argologic.com.au on 1/07/2020.
 */

global with sharing class GetRdaResponseDto extends BaseResponseDto
{
    public List<RdaResourceDto> Data {get; set;}

    public GetRdaResponseDto()
    {
        Data = new List<RdaResourceDto>();
    }
}