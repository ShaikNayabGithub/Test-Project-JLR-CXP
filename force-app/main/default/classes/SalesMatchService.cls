/**
 * Created by Nick on 1/11/2019.
 */

@RestResource(urlMapping='/v1/SalesMatch/*')
global with sharing class SalesMatchService {

    @HttpGet
    global static GetSalesMatchResponseDto getAssets() {
        GetSalesMatchResponseDto response = new GetSalesMatchResponseDto();

        try {
            GetSalesMatchRequestDto request = new GetSalesMatchRequestDto();
            Date CreatedDate = null;
            CreatedDate = JlrDateParser.parseStringAsDate(RestContext.request.params.get('CreatedDate'));
            request.CreatedDate = CreatedDate;
            response = SalesMatchController.getAssets(request);
        } catch (DateParsingException ex) {
            response.addError(ex);
        } catch (Exception ex) {
            response.addError(ex);
        }
        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }

}