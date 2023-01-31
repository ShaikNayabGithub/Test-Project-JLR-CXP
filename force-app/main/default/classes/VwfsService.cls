/**
 * Created by caleb@argologic.com.au on 23/08/2021.
 */

@RestResource(urlMapping='/v1/vwfs/*')
global with sharing class VwfsService
{
    @HttpPost
    global static VwfsResponseDto create(List<VwsfAttributeDto> request)
    {
        VwfsResponseDto response = new VwfsResponseDto();
        try
        {
            VwfsController.create(request);
        }
        catch(Exception ex)
        {
            ServiceErrorLogger.logError('/v1/vwfs/', JSON.serialize(request), ex);
            response.addError(ex);
        }
        return response;
    }
}