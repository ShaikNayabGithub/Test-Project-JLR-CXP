/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 21/10/2019.
 */

@restResource(urlMapping='/v1/WelcomePack/*')
global with sharing class WelcomePackService {

    @HttpGet
    global static GetWelcomePacksResponseDto getWelcomePacks()
    {
        GetWelcomePacksResponseDto response = null;
        GetWelcomePacksRequestDto request = new GetWelcomePacksRequestDto();
        try {
            request.dateStart = JlrDateParser.parseStringAsDatetime(RestContext.request.params.get('dateStart'));
            response = WelcomePacksController.getWelcomePacks(request);
        } catch (DateParsingException e) {
            RestContext.response.statusCode = 400;
            response.Errors.add(new ErrorDto(e));
        }

        return response;
        //mock data
        /**
        WelcomePackAttributeDto atts = new WelcomePackAttributeDto();
        atts.AddressCountry = 'Australia';
        atts.AddressLine1 = 'Suite 200';
        atts.AddressLine2 = '1 Black St';
        atts.AddressPostCode = '2000';
        atts.AddressState = 'NSW';
        atts.AddressSuburb = 'Sydney';
        atts.ContactCompanyName = 'Acme Pty Ltd';
        atts.ContactEmail = 'me@you.com';
        atts.ContactId = '100';
        atts.ContactNameFirst = 'Harry';
        atts.ContactNameLast = 'Jones';
        atts.ContactPhoneHome = '000';
        atts.ContactPhoneMobile = '111';
        atts.ContactDateOfBirth = '1970-01-01';
        atts.ContactTitle = 'Mr';
        atts.PreviousJlrVehicle = 'Range Rover';
        atts.VehicleDateWarrantyExpire = '2020-01-01';
        atts.VehicleDateWarrantyStart = '2019-01-01';
        atts.VehicleDerivative = '222';
        atts.VehicleIdentificationNumber = '012345678910123456789';
        atts.VehicleRegistrationNumber = 'AAA000';
        atts.VehicleMake = 'Jaguar';
        atts.VehicleModel = 'E-Type';
        atts.VehicleModelDetail = 'Some Detail';
        atts.ContactPhoneWork = '333';

        WelcomePackResourceDto dto = new WelcomePackResourceDto();
        dto.Attributes = atts;
        dto.Id = '111100000';
        dto.Type = 'WelcomePack';
        response.Data.add(dto);

        return response;

**/
    }
}