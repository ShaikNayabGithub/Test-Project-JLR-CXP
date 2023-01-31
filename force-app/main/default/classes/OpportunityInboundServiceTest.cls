/**
 * Created by caleb@argologic.com.au on 27/05/2020.
 */
@IsTest
public with sharing class OpportunityInboundServiceTest
{
    // compleatly valid opportunity
    @IsTest
    public static void test1()
    {
        // ARRANGE
        // we will json serialise the dto
        string reqString = '{"Data":{"Attributes":{"ProspectNameFirst":"","ProspectNameLast":"Casali","ProspectTitle":"Mr","ProspectCompanyName":"","ProspectPhoneMobile":"0414-837545","ProspectEmail":"ricky.casali@minterellison.com","RequestType":"Snoop","ItemEnquiryType":"ServiceInterception","DealerCode":"1440","ServiceDate":"1/03/2022","RetailingDealer":true,"ItemPrice":147057.11,"IsVWFS":false,"VWFSLoadId":"","ItemVehicleIdentificationNumber":"SALRA2AN3JA054004","ItemDetailsUrl":"https://app.snoop.net.au/vehicle-spec/14130426?brand_group=JLR","ItemModel":"Discovery","ItemStockNumber":"14130426","ItemMake":"Land Rover","Comments":"Other:>3YearsOwned","PurchaseType":"New","CreateActivity":true}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);
        System.debug('json = ' + JSON.serialize(req));
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        make.Name = 'Land Rover';
        make.Is_Australia__c = true;
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        model.Name = 'Discovery';
        model.Is_Australia__c = true;
        update make;
        update model;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Australia';
        insert pb;

        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        acc.PersonEmail = 'ricky.casali@minterellison.com';
        acc.LastName = 'Casali';
        update acc;
        Asset ass = new Asset();
        ass.Name = 'SALRA2AN3JA054004';
        ass.Brand__c = make.Id;
        ass.Vin__c = 'SALRA2AN3JA054004';
        ass.AccountId = acc.Id;
        ass.ContactId = acc.PersonContactId;
        insert ass;

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '01440';
        dealershipParent.Dealer_CI_Code_2__c = '01441';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '01440';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        //System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
            User u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        OpportunityInboundController.create(req);
        Test.stopTest();

        // ASSERT
        // System.assertEquals(1, [SELECT Id FROM Opportunity].size());
    }

    // invalid brand name
    @IsTest
    public static void test2()
    {
        // ARRANGE
        // we will json serialise the dto
        string reqString = '{"data": {"type": "Lead","id": "c6c4ca90-f2cb-11ea-9bbd-02a4669ca46e","attributes": {"SellerIdentifier": null,"DealerCode": "1240","Service": "Dealer Solutions Sales Highway","LeadType": "USED","ItemType": "Car","RequestType": "OEM","Status": null,"EnvironmentSiteOrigin": null,"EnvironmentPageSource": "Vehicle Details","EnvironmentIPAddress": "0.0.0.0","EnvironmentSessionId": null,"ProspectTitle": null,"ProspectNameFirst": "Angela","ProspectNameLast": "Parras","ProspectCompanyName": "N/A","ProspectAddressLine1": null,"ProspectAddressLine2": null,"ProspectAddressSuburb": null,"ProspectAddressState": null,"ProspectAddressPostcode": "2570","ProspectEmail": "angelaparrashair@outlook.com","ProspectPhoneHome": null,"ProspectPhoneMobile": "0405182560","ProspectPhoneWork": null,"ItemStockNumber": "PW20627","ItemVehicleIdentificationNumber": "SALYA2AK6JA725408","ItemMake": "Sea Rover","ItemModel": "Range Rover Velar","ItemSeries": "L560 MY18","ItemYear": 2017,"ItemPrice": 89990,"ItemRegistrationNumber": "EJA09C","ItemEngineDescription": null,"ItemTransmission": "Sports Automatic","ItemColour": "White","ItemBodyType": "SUV","ItemFuelType": "DIESEL","ItemOdometer": 29595,"ItemDetailsUrl": "https://quote.landrover.com.au/view/2017-Land-Rover-Range-Rover-Velar/22488189","TradeInMake": null,"TradeInModel": null,"TradeInYear": null,"TradeInOdometer": null,"TradeInColor": null,"Tags": ["Dealer Solutions","LeadRef:5355436"],"Comments": "Dear Landrover Concierge,  \\\\r\\\\nI have submitted \\"Make An Offer\\" Form and my offer for the vehicle 2017 Land Rover Range Rover Velar L560 MY18 D300 AWD SE White 8 Speed Sports Automatic SUV is : 82,000. my answer for reserve this vehicle is : yes\\\\r\\\\n"}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);

        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        make.Name = 'Land Rover';
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        model.Name = 'Range Rover Velar';
        update make;
        update model;

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '01240';
        dealershipParent.Dealer_CI_Code_2__c = '01241';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '01240';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
            User u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        OpportunityInboundService.create(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());
    }

    @IsTest
    public static void test3()
    {
        // ARRANGE
        // we will json serialise the dto
        string reqString = '{"Data":{"Attributes":{"ProspectNameFirst":"","ProspectNameLast":"Casali","ProspectTitle":"Mr","ProspectCompanyName":"","ProspectPhoneMobile":"0414-837545","ProspectEmail":"ricky.casali@minterellison.com","RequestType":"Snoop","ItemEnquiryType":"ServiceInterception","DealerCode":"1440","ServiceDate":"1/03/2022","RetailingDealer":true,"ItemPrice":147057.11,"IsVWFS":false,"VWFSLoadId":"","ItemVehicleIdentificationNumber":"SALRA2AN3JA054004","ItemDetailsUrl":"https://app.snoop.net.au/vehicle-spec/14130426?brand_group=JLR","ItemModel":"Discovery","ItemStockNumber":"14130426","ItemMake":"Land Rover","Comments":"Other:>3YearsOwned","PurchaseType":"New","CreateActivity":true}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);
        System.debug('json = ' + JSON.serialize(req));
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        make.Name = 'Land Rover';
        make.Is_Australia__c = true;
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        model.Name = 'Discovery';
        model.Is_Australia__c = true;
        update make;
        update model;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Australia';
        insert pb;

        Account acc = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        //acc.PersonEmail = 'ricky.casali@minterellison.com';
        acc.Name = 'Casali';
        update acc;
        Contact con1 = TestClass_ValidContactBuilder.Build(acc);
        con1.LastName = 'Casali';
        con1.Email = 'ricky.casali@minterellison.com';
        update con1;
        Asset ass = new Asset();
        ass.Name = 'SALRA2AN3JA054004';
        ass.Brand__c = make.Id;
        ass.Vin__c = 'SALRA2AN3JA054004';
        ass.AccountId = acc.Id;
        ass.ContactId = acc.PersonContactId;
        insert ass;

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '01440';
        dealershipParent.Dealer_CI_Code_2__c = '01441';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '01440';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        //System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
            User u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        OpportunityInboundController.create(req);
        Test.stopTest();

        // ASSERT
        // System.assertEquals(1, [SELECT Id FROM Opportunity].size());
    }

    @IsTest
    public static void test4()
    {
        // ARRANGE
        // we will json serialise the dto
        string reqString = '{"Data":{"Attributes":{"ProspectNameFirst":"This is a first Name","ProspectNameLast":"Casali","ProspectTitle":"Mr","ProspectCompanyName":"","ProspectPhoneMobile":"0414-837545","ProspectEmail":"ricky.casali@minterellison.com","RequestType":"Snoop","ItemEnquiryType":"ServiceInterception","DealerCode":"1440","ServiceDate":"1/03/2022","RetailingDealer":true,"ItemPrice":147057.11,"IsVWFS":false,"VWFSLoadId":"","ItemVehicleIdentificationNumber":"SALRA2AN3JA054004","ItemDetailsUrl":"https://app.snoop.net.au/vehicle-spec/14130426?brand_group=JLR","ItemModel":"Discovery","ItemStockNumber":"14130426","ItemMake":"Land Rover","Comments":"Other:>3YearsOwned","PurchaseType":"New","CreateActivity":true}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);
        System.debug('json = ' + JSON.serialize(req));
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        make.Name = 'Land Rover';
        make.Is_Australia__c = true;
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        model.Name = 'Discovery';
        model.Is_Australia__c = true;
        update make;
        update model;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Australia';
        insert pb;

        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        acc.PersonEmail = 'ricky.casali@minterellison.com';
        acc.LastName = 'Casali';
        update acc;
        Asset ass = new Asset();
        ass.Name = 'SALRA2AN3JA054004';
        ass.Brand__c = make.Id;
        ass.Vin__c = 'SALRA2AN3JA054004';
        ass.AccountId = acc.Id;
        ass.ContactId = acc.PersonContactId;
        insert ass;

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '01440';
        dealershipParent.Dealer_CI_Code_2__c = '01441';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '01440';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        //System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
            User u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        OpportunityInboundController.create(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(1, [SELECT Id FROM Opportunity].size());
    }

    @IsTest
    public static void getContactTest()
    {
        string reqString = '{"Data":{"Attributes":{"ProspectNameFirst":"","ProspectNameLast":"Casali","ProspectTitle":"Mr","ProspectCompanyName":"","ProspectPhoneMobile":"0414-837545","ProspectEmail":"ricky.casali@minterellison.com","RequestType":"Snoop","ItemEnquiryType":"ServiceInterception","DealerCode":"1440","ServiceDate":"1/03/2022","RetailingDealer":true,"ItemPrice":147057.11,"IsVWFS":false,"VWFSLoadId":"","ItemVehicleIdentificationNumber":"SALRA2AN3JA054004","ItemDetailsUrl":"https://app.snoop.net.au/vehicle-spec/14130426?brand_group=JLR","ItemModel":"Discovery","ItemStockNumber":"14130426","ItemMake":"Land Rover","Comments":"Other:>3YearsOwned","PurchaseType":"New","CreateActivity":true}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);

        Account acc = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        //acc.PersonEmail = 'ricky.casali@minterellison.com';
        acc.Name = 'Casali';
        update acc;

        OpportunityInboundController.getContact(req.Data.Attributes, acc);
    }

    @IsTest
    public static void getAccountTest()
    {
        string reqString = '{"Data":{"Attributes":{"ProspectNameFirst":"","ProspectNameLast":"Casali","ProspectTitle":"Mr","ProspectCompanyName":"","ProspectPhoneMobile":"0414-837545","ProspectEmail":"ricky.casali@minterellison.com","RequestType":"Snoop","ItemEnquiryType":"ServiceInterception","DealerCode":"1440","ServiceDate":"1/03/2022","RetailingDealer":true,"ItemPrice":147057.11,"IsVWFS":false,"VWFSLoadId":"","ItemVehicleIdentificationNumber":"SALRA2AN3JA054004","ItemDetailsUrl":"https://app.snoop.net.au/vehicle-spec/14130426?brand_group=JLR","ItemModel":"Discovery","ItemStockNumber":"14130426","ItemMake":"Land Rover","Comments":"Other:>3YearsOwned","PurchaseType":"New","CreateActivity":true}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);
        req.Data.Attributes.ProspectCompanyName = 'ttestasdas ';

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '01440';
        dealershipParent.Dealer_CI_Code_2__c = '01441';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '01440';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        //System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User u;
        System.runAs(thisUser)
        {
            u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        OpportunityInboundController.getAccount(req.Data.Attributes, dealership, u.Id);
    }

    @IsTest
    public static void newtest1()
    {
        // ARRANGE
        // we will json serialise the dto
        string reqString = '{"data": {"type": "Opportunity","id": "10833b50-9cf1-11ec-ad5e-0ac0dc546616","attributes": {"DealerCode": "3241","PurchaseType": "NEW","ItemEnquiryType": "Find & Price Enquiry","ItemType": "Find & Price Enquiry","RequestType": "DEALER","ProspectPreferredTestDriveDate": null,"ProspectTitle": null,"ProspectNameFirst": "Lauren","ProspectNameLast": "Hope","ProspectCompanyName": "N/A","ProspectAddressLine1": null,"ProspectAddressLine2": null,"ProspectAddressSuburb": null,"ProspectAddressState": null,"ProspectAddressPostcode": null,"ProspectEmail": "lauren@rsmarketing.com.au","ProspectPhoneHome": null,"ProspectPhoneMobile": "0427865377","ProspectPhoneWork": null,"ItemStockNumber": "16378167","ItemVehicleIdentificationNumber": "SALCA2AX3NH912205","ItemMake": "LAND_ROVER","ItemModel": "Discovery Sport","ItemSeries": "L550 22MY","ItemYear": 2022,"ItemPrice": 94002,"ItemRegistrationNumber": null,"ItemEngineDescription": "2.0 i4 183kW Petrol","ItemTransmission": "Automatic","ItemColour": "Fuji White","ItemBodyType": "Wagon","ItemFuelType": "PETROL","ItemOdometer": 0,"ItemDetailsUrl": "https://quote.landrover.com.au/south_brisbane/view/2022-Land-Rover-Discovery-Sport/26315415","TradeInMake": null,"TradeInModel": null,"TradeInYear": null,"TradeInOdometer": null,"TradeInColor": null,"Comments": "Dear Landrover Concierge,\\\\r\\\\nI have submitted \\"Enquire Now\\" Form and my query for the vehicle Discovery Sport P250 R-Dynamic SE AWD Auto 22MY is : . my answer for arrange a test drive for this vehicle is : yes\\\\r\\\\n"}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);
        System.debug('json = ' + JSON.serialize(req));
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        make.Name = 'Land Rover';
        make.Is_Australia__c = true;
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        model.Name = 'Discovery Sport';
        model.Is_Australia__c = true;
        update make;
        update model;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Australia';
        insert pb;

        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        acc.PersonEmail = 'ricky.casali@minterellison.com';
        acc.LastName = 'Casali';
        update acc;
        Asset ass = new Asset();
        ass.Name = 'SALRA2AN3JA054004';
        ass.Brand__c = make.Id;
        ass.Vin__c = 'SALRA2AN3JA054004';
        ass.AccountId = acc.Id;
        ass.ContactId = acc.PersonContactId;
        insert ass;

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '03241';
        dealershipParent.Dealer_CI_Code_2__c = '03242';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '03241';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        //System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
            User u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        OpportunityInboundController.create(req);
        Test.stopTest();

        // ASSERT
        // System.assertEquals(1, [SELECT Id FROM Opportunity].size());
    }

    @IsTest
    public static void newtest2()
    {
        // ARRANGE
        // we will json serialise the dto
        string reqString = '{"data": {"type": "Opportunity","id": "10833b50-9cf1-11ec-ad5e-0ac0dc546616","attributes": {"DealerCode": "3241","PurchaseType": "NEW","ItemEnquiryType": "Find & Price Enquiry","ItemType": "Find & Price Enquiry","RequestType": "DEALER","ProspectPreferredTestDriveDate": null,"ProspectTitle": null,"ProspectNameFirst": "Lauren","ProspectNameLast": "Hope","ProspectCompanyName": "Telstra","ProspectAddressLine1": null,"ProspectAddressLine2": null,"ProspectAddressSuburb": null,"ProspectAddressState": null,"ProspectAddressPostcode": null,"ProspectEmail": "lauren@rsmarketing.com.au","ProspectPhoneHome": null,"ProspectPhoneMobile": "0427865377","ProspectPhoneWork": null,"ItemStockNumber": "16378167","ItemVehicleIdentificationNumber": "SALCA2AX3NH912205","ItemMake": "LAND_ROVER","ItemModel": "Discovery Sport","ItemSeries": "L550 22MY","ItemYear": 2022,"ItemPrice": 94002,"ItemRegistrationNumber": null,"ItemEngineDescription": "2.0 i4 183kW Petrol","ItemTransmission": "Automatic","ItemColour": "Fuji White","ItemBodyType": "Wagon","ItemFuelType": "PETROL","ItemOdometer": 0,"ItemDetailsUrl": "https://quote.landrover.com.au/south_brisbane/view/2022-Land-Rover-Discovery-Sport/26315415","TradeInMake": null,"TradeInModel": null,"TradeInYear": null,"TradeInOdometer": null,"TradeInColor": null,"Comments": "Dear Landrover Concierge,\\\\r\\\\nI have submitted \\"Enquire Now\\" Form and my query for the vehicle Discovery Sport P250 R-Dynamic SE AWD Auto 22MY is : . my answer for arrange a test drive for this vehicle is : yes\\\\r\\\\n"}}}';
        CreateOpportunityInboundRequestDto req = (CreateOpportunityInboundRequestDto)Json.deserialize(reqString, CreateOpportunityInboundRequestDto.class);
        System.debug('json = ' + JSON.serialize(req));
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        make.Name = 'Land Rover';
        make.Is_Australia__c = true;
        Vehicle_Specification__c model = TestClass_VehicleSpecificationBuilder.BuildModel(make);
        model.Name = 'Discovery Sport';
        model.Is_Australia__c = true;
        update make;
        update model;

        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Australia';
        insert pb;

        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        acc.PersonEmail = 'ricky.casali@minterellison.com';
        acc.LastName = 'Casali';
        update acc;
        Asset ass = new Asset();
        ass.Name = 'SALRA2AN3JA054004';
        ass.Brand__c = make.Id;
        ass.Vin__c = 'SALRA2AN3JA054004';
        ass.AccountId = acc.Id;
        ass.ContactId = acc.PersonContactId;
        insert ass;

        Account dealershipParent = TestClass_AccountCreator.BuildRetailer();
        dealershipParent.Dealer_CI_Code__c = '03241';
        dealershipParent.Dealer_CI_Code_2__c = '03242';
        insert dealershipParent;

        Account dealership = TestClass_AccountCreator.BuildRetailer();
        dealership.Dealer_CI_Code__c = '03241';
        dealership.ParentId = dealershipParent.Id;
        insert dealership;

        System.debug('dealershipId = ' + dealership.Id);

        Contact con = TestClass_ValidContactBuilder.Build(dealershipParent);
        con.LastName = 'Triviet Default User';
        update con;
        //System.debug([SELECT Name FROM Contact].Name);

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser)
        {
            User u = TestClass_UserCreator.CreateRetailerUser(con);
        }

        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();

        // ACT
        Test.startTest();
        OpportunityInboundController.create(req);
        Test.stopTest();

        // ASSERT
        // System.assertEquals(1, [SELECT Id FROM Opportunity].size());
    }
}