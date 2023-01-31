/**
 * Created by caleb@argologic.com.au on 1/07/2020.
 */

@RestResource(urlMapping='/v1/SnoopDog/rda/*')
global with sharing class SnoopDogRdaService
{
    @HttpGet
    global static GetRdaResponseDto get()
    {
        try
        {
            Datetime startDatetime = JlrDateParser.parseStringAsDatetime(RestContext.request.params.get('dateStart'));
            GetRdaRequestDto req = new GetRdaRequestDto();
            req.StartDatetime = startDatetime;
            GetRdaResponseDto res = SnoopDogRdaController.get(req);
            return res;
        }
        catch (Exception ex)
        {
            GetRdaResponseDto res = new GetRdaResponseDto();
            res.addError(ex);
            return res;
        }
    }
}