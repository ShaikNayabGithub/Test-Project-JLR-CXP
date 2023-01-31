/**
 * Created by Ethan Sargent on 16/10/19.
 */

@RestResource(UrlMapping='/v1/QantasFrequentFlyer')
global with sharing class QantasFrequentFlyerService
{
    @HttpGet
    global static QantasFrequentFlyerResponseDto get()
    {
        try
        {
            GetQantasFrequentFlyerRequestDto request = new GetQantasFrequentFlyerRequestDto();
            request.StartDatetime = JlrDateParser.parseStringAsDatetime(RestContext.request.params.get('dateStart'));
            if (request.StartDatetime == null) {
                throw new DateParsingException();
            }
            return QantasController.FetchQantasFrequentFlyerTransactions(request);
        }
        catch (DateParsingException ex)
        {
            QantasFrequentFlyerResponseDto response = new QantasFrequentFlyerResponseDto();
            ErrorDto err = new ErrorDto(ex);
            response.Errors = new List<ErrorDto>();
            response.Errors.add(err);
            RestContext.response.statusCode = 400;
            return response;
        }
    }
}