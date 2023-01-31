/**
 * Created by caleb on 2/10/2019.
 * https://argologic.atlassian.net/browse/JLR-125
 */

@RestResource(urlMapping='/v1/ServiceEvent/*')
global with sharing class ServiceEventService
{
    @HttpPost
    global static CreateServiceEventResponseDto create(CreateServiceEventRequestDto request)
    {
        return ServiceEventController.create(request);
    }
}