/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 4/11/2019.
 */
@RestResource(urlMapping='/v1/RetailDelivery/*')
global with sharing class RetailDeliveryService {

    @HttpGet
    global static GetRetailDeliveryAdvicesResponseDto get(){
        GetRetailDeliveryAdvicesResponseDto response = new GetRetailDeliveryAdvicesResponseDto();
        try{
            // Reading parameters from URL
            RestRequest restReq = RestContext.request;
            String dateStart = restReq.params.get('dateStart');
            Date startDate = JlrDateParser.parseStringAsDate(dateStart);
            if (startDate == null){
                throw new DateParsingException();
            }
            response = RetailDeliveryController.getRetailDeliveryAdvices(new GetRetailDeliveryAdvicesRequestDto(startDate));
        }
        catch(DateParsingException ex){
            response.addError(ex);
        }
        catch(Exception ex){
            response.addError(ex);
        }
        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }
}