/**
 * Created by caleb on 6/09/2019.
 */

@IsTest
public with sharing class LeadsControllerTest
{
    @IsTest
    public static void coverageForDtos()
    {
        CreateLeadRequestDto req = new CreateLeadRequestDto();
        LeadResourceDto res = new LeadResourceDto();
    }

    @IsTest
    public static void CreateSimpleTest()
    {
        //ARRANGE
        String jsonBody = '{"Data": {"Type": "Lead","Id": "","Attributes": {"SellerIdentifier": "cb41a639-76d4-4f8d-adfa-efce175c35f0","Service": "ExampleService","LeadType": "NEW","ItemType": "Car","RequestType": "DEALER","Status": "New","EnvironmentSiteOrigin": "carsales.com.au","EnvironmentPageSource": "details","EnvironmentIPAddress": "12.12.12.12","EnvironmentSessionId": "0deb7106-4b7b-4cee-a29e-8777b11a336d","ProspectTitle": "Mr","ProspectNameFirst": "Barry","ProspectNameLast": "Bloke","ProspectCompanyName": "XYZLtd","ProspectAddressLine1": "Unit 9","ProspectAddressLine2": "31TheAvenue","ProspectAddressSuburb": "Smalltown","ProspectAddressState": "VIC","ProspectAddressPostcode": "3111","ProspectEmail": "barry@bloke.com","ProspectPhoneHome": "0397845346","ProspectPhoneMobile": "0411111111","ProspectPhoneWork": "0398765432","ItemStockNumber": "ABC123","ItemMake": "JAGUAR","ItemModel": "Focus","Tags": ["MobileDevice","DetailsPage","XYZCampaign"],"Comments": "anycommentstheprospecthasincluded,e.g.questions"}}}';
        CreateLeadRequestDto req = (CreateLeadRequestDto)JSON.deserialize(jsonBody, CreateLeadRequestDto.class);
        System.debug(JSON.serialize(req));
        RestContext.response = new RestResponse();

        //ACT
        Test.startTest();
        CreateLeadResponseDto response = LeadsService.create((CreateLeadRequestDto)req);
        Test.stopTest();

        //ASSERT
        System.debug(Json.serialize(response));
        System.assertNotEquals(null, response);
        // make sure a single lead was created in the database
        List<Lead> leads = [SELECT Id, Preferred_Retailer__c FROM Lead];
        System.assertEquals(1, leads.size());
        System.assertEquals(response.Data.Id, leads[0].Id);
    }

    @IsTest
    public static void CreateWithDealerCodeTest()
    {
        //ARRANGE
        // make dealer
        Account dealer = TestClass_AccountCreator.CreateRetailer();
        Account parentDealer = TestClass_AccountCreator.CreateRetailer();
        dealer.Dealer_CI_Code__c = '01234';
        dealer.ParentId = parentDealer.Id;
        update dealer;
        String jsonBody = '{"Data": {"Type": "Lead","Id": "","Attributes": {"SellerIdentifier": "cb41a639-76d4-4f8d-adfa-efce175c35f0","DealerCode": "1234","Service": "ExampleService","LeadType": "NEW","ItemType": "Car","RequestType": "DEALER","Status": "New","EnvironmentSiteOrigin": "carsales.com.au","EnvironmentPageSource": "details","EnvironmentIPAddress": "12.12.12.12","EnvironmentSessionId": "0deb7106-4b7b-4cee-a29e-8777b11a336d","ProspectTitle": "Mr","ProspectNameFirst": "Barry","ProspectNameLast": "Bloke","ProspectCompanyName": "XYZLtd","ProspectAddressLine1": "Unit 9","ProspectAddressLine2": "31TheAvenue","ProspectAddressSuburb": "Smalltown","ProspectAddressState": "VIC","ProspectAddressPostcode": "3111","ProspectEmail": "barry@bloke.com","ProspectPhoneHome": "0397845346","ProspectPhoneMobile": "0411111111","ProspectPhoneWork": "0398765432","ItemStockNumber": "ABC123","ItemMake": "JAGUAR","ItemModel": "Focus","Tags": ["MobileDevice","DetailsPage","XYZCampaign"],"Comments": "anycommentstheprospecthasincluded,e.g.questions"}}}';
        CreateLeadRequestDto req = (CreateLeadRequestDto)JSON.deserialize(jsonBody, CreateLeadRequestDto.class);
        System.debug(JSON.serialize(req));
        RestContext.response = new RestResponse();

        //ACT
        Test.startTest();
        CreateLeadResponseDto response = LeadsService.create((CreateLeadRequestDto)req);
        Test.stopTest();

        //ASSERT
        System.debug(Json.serialize(response));
        System.assertNotEquals(null, response);
        // make sure a single lead was created in the database
        List<Lead> leads = [SELECT Id, Preferred_Retailer__c FROM Lead];
        System.assertEquals(1, leads.size());
        // assert the Preferred_Retailer__c is correctly mapped
        System.assertEquals(dealer.Id, leads[0].Preferred_Retailer__c);
        System.assertEquals(response.Data.Id, leads[0].Id);
    }

    @IsTest
    public static void CreateWithInvalidTest()
    {
        //ARRANGE
        // make dealer
        Account dealer = TestClass_AccountCreator.CreateRetailer();
        Account parentDealer = TestClass_AccountCreator.CreateRetailer();
        dealer.Dealer_CI_Code__c = '01234';
        dealer.ParentId = parentDealer.Id;
        update dealer;
        String jsonBody = '{"Data": {"Type": "Lead","Id": "","Attributes": {"SellerIdentifier": "cb41a639-76d4-4f8d-adfa-efce175c35f0","DealerCode": "1234","Service": "ExampleService","LeadType": "NEW","ItemType": "Car","RequestType": "DEALER","Status": "New","EnvironmentSiteOrigin": "carsales.com.au","EnvironmentPageSource": "details","EnvironmentIPAddress": "12.12.12.12","EnvironmentSessionId": "0deb7106-4b7b-4cee-a29e-8777b11a336d","ProspectTitle": "Mr","ProspectNameFirst": "Barry","ProspectNameLast": "Bloke","ProspectCompanyName": "XYZLtd","ProspectAddressLine1": "Unit 9","ProspectAddressLine2": "31TheAvenue","ProspectAddressSuburb": "Smalltown", "ProspectPreferredTestDriveDate": "12/18/2019","ProspectAddressState": "VIC","ProspectAddressPostcode": "3111","ProspectEmail": "barry@bloke.com","ProspectPhoneHome": "0397845346","ProspectPhoneMobile": "0411111111","ProspectPhoneWork": "0398765432","ItemStockNumber": "ABC123","ItemMake": "JAGUAR","ItemModel": "Focus","Tags": ["MobileDevice","DetailsPage","XYZCampaign"],"Comments": "anycommentstheprospecthasincluded,e.g.questions"}}}';
        CreateLeadRequestDto req = (CreateLeadRequestDto)JSON.deserialize(jsonBody, CreateLeadRequestDto.class);
        System.debug(JSON.serialize(req));
        RestContext.response = new RestResponse();

        //ACT
        Test.startTest();
        CreateLeadResponseDto response = LeadsService.create((CreateLeadRequestDto)req);
        Test.stopTest();

        //ASSERT
        System.debug(Json.serialize(response));
        System.assertNotEquals(null, response);
        // make sure a single lead was created in the database
        List<Lead> leads = [SELECT Id, Preferred_Retailer__c FROM Lead];
        System.assertEquals(0, leads.size());
    }
}