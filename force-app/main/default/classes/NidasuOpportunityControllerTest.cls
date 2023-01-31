/**
 * Created by caleb@argologic.com.au on 30/10/2019.
 */

@IsTest
private class NidasuOpportunityControllerTest
{

    @isTest
    static GetNidasuOpportunityRequestDto GetSendRequestDto1()
    {
        // Creates all required data and updates fields
        Account acc = TestClass_AccountCreator.CreatePersonAccount();
        acc.Type = 'Other';
        acc.PersonFirstNameLocal = 'Test First Name';
        acc.PersonLastNameLocal = 'Test Last Name';
        acc.PersonMobilePhone = '0421000000';
        acc.Phone = '0200000000';
        acc.PersonHomePhone = '0200000000';
        acc.PersonEmail = 'test@test.com';
        acc.BillingStreet = '11 Martin Pl';
        acc.BillingCity = 'Sydney';
        acc.BillingState = 'NSW';
        acc.BillingPostalCode = '2000';
        acc.BillingCountry = 'Australia';
        update acc;
        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity(ass.Id, acc.Id);
        opp.Sale_Type__c = 'New';
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        opp.Brand__c = make.Id;
        opp.Primary_Model_Interest__c = model.Id;
        opp.VIN__c = '12345678';
        opp.Retailer__c = TestClass_AccountCreator.CreateRetailer().Id;
        update opp;
        System.debug('Brand Name = ' + opp.Brand__r.Name);
        GetNidasuOpportunityRequestDto request = new GetNidasuOpportunityRequestDto();
        request.OpportunityId = opp.Id;
        return request;
    }

    @isTest
    static GetNidasuOpportunityRequestDto GetSendRequestDto2()
    {
        // Creates all required data and updates fields
        Account acc = TestClass_AccountCreator.CreatePersonAccount();
        acc.Type = 'Other';
        acc.PersonFirstNameLocal = 'Test First Name';
        acc.PersonLastNameLocal = 'Test Last Name';
        acc.PersonMobilePhone = '0421000000';
        acc.Phone = '0200000000';
        acc.PersonHomePhone = '0200000000';
        acc.PersonEmail = 'test@test.com';
        acc.BillingStreet = '11 Martin Pl';
        acc.BillingCity = 'Sydney';
        acc.BillingState = 'NSW';
        acc.BillingPostalCode = '2000';
        acc.BillingCountry = 'Australia';
        acc.PersonMailingStreet = '11 Martin Pl';
        acc.PersonMailingCity = 'Sydney';
        acc.PersonMailingState = 'NSW';
        acc.PersonMailingPostalCode = '2000';
        acc.PersonMailingCountry = 'Australia';
        update acc;
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
        Asset ass = TestClass_AssetBuilder.BuildVehicle();
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity(ass.Id, acc.Id);
        opp.Sale_Type__c = 'New';
        opp.Primary_Contact__c = con.Id;
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        opp.Brand__c = make.Id;
        opp.Primary_Model_Interest__c = model.Id;
        opp.VIN__c = '12345678';
        opp.Retailer__c = TestClass_AccountCreator.CreateRetailer().Id;
        update opp;
        System.debug('Brand Name = ' + opp.Brand__r.Name);
        GetNidasuOpportunityRequestDto request = new GetNidasuOpportunityRequestDto();
        request.OpportunityId = opp.Id;
        Opportunity res = [SELECT Primary_Contact__r.MailingStreet, Primary_Contact__c FROM Opportunity];
        return request;
    }

    @IsTest
    static void sendOpportunityTest1()
    {
        // ARRANGE
        Test.setMock(HttpCalloutMock.class, new NidasuOpportunityToMulesoftMockImpl());
        GetNidasuOpportunityRequestDto request = GetSendRequestDto1();

        // ACT
        Test.startTest();
        String respose = NidasuOpportunityController.sendOpportunity(request);
        Test.stopTest();

        // ASSERT
        // check the request to the mock impl was valid
        System.debug(respose);
        system.assertEquals(respose, 'Sync Success');
    }

    @IsTest
    static void sendOpportunityTest2()
    {
        // ARRANGE
        Test.setMock(HttpCalloutMock.class, new NidasuOpportunityToMulesoftMockImpl());
        GetNidasuOpportunityRequestDto request = GetSendRequestDto2();

        // ACT
        Test.startTest();
        String respose = NidasuOpportunityController.sendOpportunity(request);
        Test.stopTest();

        // ASSERT
        // check the request to the mock impl was valid
        System.debug(respose);
        system.assertEquals(respose, 'Sync Success');
    }
}