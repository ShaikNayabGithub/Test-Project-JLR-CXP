/**
 * Created by caleb on 12/09/2019.
 */

@RestResource(urlMapping='/v1/IntegrationEvents/*')
global with sharing class IntegrationEventsService {

    @HttpPost
    global static CreateIntegrationEventResponseDto create(CreateIntegrationEventRequestDto request) {
        CreateIntegrationEventResponseDto response = new CreateIntegrationEventResponseDto();
        try {
            response = IntegrationEventController.createEvent(request);
        } catch (Exception ex) {
            response.addError(ex);
        }
        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }
}