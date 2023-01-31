/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 1/11/2019.
 */

@RestResource(urlMapping='/v1/RoadsideServiceEvent/*')
global with sharing class RoadsideServiceEventService {

    @HttpPost
    global static CreateRoadsideServiceEventResponseDto create(CreateRoadsideServiceEventRequestDto request){
        return ServiceEventController.create(request);
    }
}