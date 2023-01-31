/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 24/10/2019.
 */

@IsTest
private class ServiceEvent_Test {
    @TestSetup
    static void buildData(){
        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        ass.VIN__c = 'VIN000111222333';
        insert ass;

    }


    @IsTest
    static void createTest_Positive() {

        //ARRANGE
        CreateServiceEventRequestDto request  = (CreateServiceEventRequestDto)JSON.deserialize('{ "Data": [ { "Type": "ServiceEvent", "Id": "198074", "Attributes": { "DatabaseReferenceId": "198074", "CorporateAccIndicator": "", "CompanyName": "", "ContactTitle": "Mrs", "ContactNameFirst": "Carmel", "ContactNameLast": null, "ContactEmail": "carmelsciarpa@gmail.com", "ContactPhoneMobile": "411144559", "ContactPhoneHome": "", "ContactPhoneWork": "", "AddressLine1": "16 Fernlea Cres", "AddressLine2": "", "AddressSuburb": "Doncaster East", "AddressState": "", "AddressPostCode": "3109", "AddressCountry": "Australia", "VehicleType": "", "VehicleIdentificationNumber": "VIN000111222333", "VehicleRegistrationNumber": "AGO698", "VehicleBrand": "Land Rover", "VehicleModel": "Range Rover", "VehicleDerivative": "", "VehicleDmsId": "105495", "VehicleDmsInvoiceRefId": "", "RepairOrderNumber": "", "EventDateJobBooked": "", "EventDateRepaired": "5/2/2018", "EventDealerCodeJlr": "2160", "EventRepairingRetailerName": "Doncaster Land Rover", "SrType": "", "Description": "", "VehicleMileage": "47789", "VehicleMileageDate": "5/2/2018", "VehicleMileageUnitOfMeasure": "", "PriceInvoice": "66.47", "PriceParts": "0", "PriceLabour": "66.47", "VehicleRoadworthinessInspectionDate": "", "VehicleLatestRegistrationDate": "", "JobCode": "", "PrivacyCode": "", "IsRepeatRepair": false, "ServiceAdvisorName": "", "WorkOrderContactTitle": "Mrs", "WorkOrderContactFirstName": "Carmel", "WorkOrderContactLastName": "Sciarpa", "WorkOrderContactPhoneHome": "", "WorkOrderContactPhoneWork": "", "WorkOrderContactPhoneMobile": "0411-144559", "WorkOrderContactEmail": "carmelsciarpa@gmail.com" } }] }', CreateServiceEventRequestDto.class);


        //ACT
        Test.startTest();
        CreateServiceEventResponseDto response = ServiceEventService.create(request);
        Test.stopTest();


        //ASSERT
        System.assert(response.Errors == null || response.Errors.size() == 0);
        System.assertNotEquals(null, response.Data);
        System.assertEquals(1, response.Data.size());
        System.assertNotEquals(null, response.Data[0].Id);
        System.assertEquals('VIN000111222333', response.Data[0].Attributes.VehicleIdentificationNumber);

    }

    @IsTest
    static void createTest_Negative_BadDate() {

        //ARRANGE
        CreateServiceEventRequestDto request  = (CreateServiceEventRequestDto)JSON.deserialize('{ "Data": [ { "Type": "ServiceEvent", "Id": "198074", "Attributes": { "DatabaseReferenceId": "198074", "CorporateAccIndicator": "", "CompanyName": "", "ContactTitle": "Mrs", "ContactNameFirst": "Carmel", "ContactNameLast": null, "ContactEmail": "carmelsciarpa@gmail.com", "ContactPhoneMobile": "411144559", "ContactPhoneHome": "", "ContactPhoneWork": "", "AddressLine1": "16 Fernlea Cres", "AddressLine2": "", "AddressSuburb": "Doncaster East", "AddressState": "", "AddressPostCode": "3109", "AddressCountry": "Australia", "VehicleType": "", "VehicleIdentificationNumber": "VIN000111222333", "VehicleRegistrationNumber": "AGO698", "VehicleBrand": "Land Rover", "VehicleModel": "Range Rover", "VehicleDerivative": "", "VehicleDmsId": "105495", "VehicleDmsInvoiceRefId": "", "RepairOrderNumber": "", "EventDateJobBooked": "", "EventDateRepaired": "55/2/2018", "EventDealerCodeJlr": "2160", "EventRepairingRetailerName": "Doncaster Land Rover", "SrType": "", "Description": "", "VehicleMileage": "47789", "VehicleMileageDate": "5/2/2018", "VehicleMileageUnitOfMeasure": "", "PriceInvoice": "66.47", "PriceParts": "0", "PriceLabour": "66.47", "VehicleRoadworthinessInspectionDate": "", "VehicleLatestRegistrationDate": "", "JobCode": "", "PrivacyCode": "", "IsRepeatRepair": false, "ServiceAdvisorName": "", "WorkOrderContactTitle": "Mrs", "WorkOrderContactFirstName": "Carmel", "WorkOrderContactLastName": "Sciarpa", "WorkOrderContactPhoneHome": "", "WorkOrderContactPhoneWork": "", "WorkOrderContactPhoneMobile": "0411-144559", "WorkOrderContactEmail": "carmelsciarpa@gmail.com" } }] }', CreateServiceEventRequestDto.class);


        //ACT
        Test.startTest();
        CreateServiceEventResponseDto response = ServiceEventService.create(request);
        Test.stopTest();


        //ASSERT
        System.assert(response.Data == null || response.Data.size() == 0);
        System.assertNotEquals(null, response.Errors);
        System.assertEquals(1, response.Errors.size());
        System.assertEquals(DateParsingException.class.getName(), response.Errors[0].ErrorCode);

    }
}