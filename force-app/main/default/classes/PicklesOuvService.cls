/**
 * Created by Nick on 16/10/2019.
 */

@RestResource(urlMapping='/v1/Pickles/Ouv/*')
global with sharing class PicklesOuvService {
    
    @HttpGet
    global static GetPicklesOuvResponseDto getAssets()
    {
        GetPicklesOuvResponseDto response = new GetPicklesOuvResponseDto();

        try{
            GetPicklesOUVRequestDto request = new GetPicklesOUVRequestDto();
            Date dateFrom = null;
            dateFrom = JlrDateParser.parseStringAsDate(RestContext.request.params.get('dateFrom'));
            request.DateFrom = dateFrom;
            response = PicklesOuvController.getAssets(request);
        }
        catch (DateParsingException ex){
            response.addError(ex);
        }
        catch (Exception ex){
            response.addError(ex);
        }
        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }

}