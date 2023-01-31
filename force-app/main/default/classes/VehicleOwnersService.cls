/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 11/10/2019.
 */

@RestResource(urlMapping='/v1/VehicleOwners/*')
global with sharing class VehicleOwnersService {

    @HttpGet
    global static GetVehicleOwnersResponseDto getVehicleOwners()
    {
        GetVehicleOwnersResponseDto response = new GetVehicleOwnersResponseDto();
        try
        {
            GetVehicleOwnersRequestDto request = new GetVehicleOwnersRequestDto();
            request.DateStart = JlrDateParser.parseStringAsDatetime(RestContext.request.params.get('dateStart'));
            if (RestContext.request.params.containsKey('startNumber'))
                request.StartNumber = RestContext.request.params.get('startNumber');
            response = VehicleOwnersController.getVehicleOwners(request);
        } catch (Exception ex)
        {
            response.addError(ex);
        }

        RestContext.response.statusCode = response.IsSuccess ? 200 : 400;
        return response;
    }

}