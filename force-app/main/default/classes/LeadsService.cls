/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

@RestResource(urlMapping='/v1/leads/*')
global with sharing class LeadsService {

    @HttpPost
    global static CreateLeadResponseDto create(CreateLeadRequestDto request){
        CreateLeadResponseDto response = new CreateLeadResponseDto();
        try{
            response = LeadsController.create(request);
        }
        catch(Exception ex){
            ServiceErrorLogger.logError('/v1/leads/', JSON.serialize(request), ex);
            response.addError(ex);
        }
        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }
}