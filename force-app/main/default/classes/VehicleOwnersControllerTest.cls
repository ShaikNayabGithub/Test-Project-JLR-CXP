/**
 * Created by caleb@argologic.com.au on 29/11/2019.
 */

@IsTest
public with sharing class VehicleOwnersControllerTest
{
    @IsTest
    public static void getVehicleOwnersTest()
    {
        // ARRANGE
        // Set Mock Because some trigger from a different region makes a web service callout
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        // setup data
        Role__c role = TestClass_AssetRoleCreator.Create(VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER);
        role = [SELECT Account__r.Country_ISO_Code__c, Account__c, Contact__c, Account__r.PersonContactId, Vehicle__c FROM Role__c];
        role.Contact__c = role.Account__r.PersonContactId;
        role.Account__r.Country_ISO_Code__c = Constants.COUNTRY_CODE_AU;
        role.Account__r.BillingStreet = '1351 Test St';
        role.Account__r.ShippingStreet = '1351 Test St';
        role.Account__r.Vehicle_Owner_Date_Last_Changed__c = Datetime.now().addMonths(1);
        Test.startTest(); // This is Joe's solution to the too many soql problem (move Test.startTest() to the wrong spot)
        RDA__c rda = TestClass_RDACreater.CreateRDA(TestClass_OpportunityCreator.generateOpportunity().Id, TestClass_AccountCreator.GenerateCorporateAccount().Id, role.Account__c, role.Vehicle__c);
        update role.Account__r;
        update role;
        // setup request
        GetVehicleOwnersRequestDto req = new GetVehicleOwnersRequestDto();
        req.DateStart = Datetime.now().addDays(-1);
        req.StartNumber = '0';

        // ACT
        // Test.startTest()
        GetVehicleOwnersResponseDto res = VehicleOwnersController.getVehicleOwners(req);
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(res));
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    public static void getVehicleOwnersTest2()
    {
        // ARRANGE
        // Set Mock Because some trigger from a different region makes a web service callout
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        // setup data
        Role__c role = TestClass_AssetRoleCreator.Create(VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER);
        role = [SELECT Account__r.Country_ISO_Code__c, Account__c, Contact__c, Account__r.PersonContactId, Vehicle__c FROM Role__c];
        role.Contact__c = role.Account__r.PersonContactId;
        role.Account__r.Country_ISO_Code__c = Constants.COUNTRY_CODE_AU;
        role.Account__r.ShippingStreet = '1351 Test St';
        role.Account__r.Vehicle_Owner_Date_Last_Changed__c = Datetime.now().addMonths(1);
        Test.startTest(); // This is Joe's solution to the too many soql problem (move Test.startTest() to the wrong spot)
        RDA__c rda = TestClass_RDACreater.CreateRDA(TestClass_OpportunityCreator.generateOpportunity().Id, TestClass_AccountCreator.GenerateCorporateAccount().Id, role.Account__c, role.Vehicle__c);
        update role.Account__r;
        update role;
        // setup request
        GetVehicleOwnersRequestDto req = new GetVehicleOwnersRequestDto();
        req.DateStart = Datetime.now().addDays(-1);
        req.StartNumber = '0';

        // ACT
        // Test.startTest()
        GetVehicleOwnersResponseDto res = VehicleOwnersController.getVehicleOwners(req);
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(res));
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    public static void getVehicleOwnersTest3()
    {
        // ARRANGE
        // Set Mock Because some trigger from a different region makes a web service callout
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        // setup data
        Role__c role = TestClass_AssetRoleCreator.Create(VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER);
        role = [SELECT Account__r.Country_ISO_Code__c, Account__c, Contact__c, Account__r.PersonContactId, Vehicle__c FROM Role__c];
        role.Contact__c = role.Account__r.PersonContactId;
        Account corpoAccount = TestClass_AccountCreator.GenerateCorporateAccount();
        role.Account__c = corpoAccount.Id;
        role.Account__r = corpoAccount;
        role.Account__r.Country_ISO_Code__c = Constants.COUNTRY_CODE_AU;
        role.Account__r.BillingStreet = '1351 Test St';
        role.Account__r.ShippingStreet = '1351 Test St';
        role.Account__r.Vehicle_Owner_Date_Last_Changed__c = Datetime.now().addMonths(1);
        Test.startTest(); // This is Joe's solution to the too many soql problem (move Test.startTest() to the wrong spot)

        RDA__c rda = TestClass_RDACreater.CreateRDA(TestClass_OpportunityCreator.generateOpportunity().Id, corpoAccount.Id, role.Account__c, role.Vehicle__c);
        update role.Account__r;
        update role;
        // setup request
        GetVehicleOwnersRequestDto req = new GetVehicleOwnersRequestDto();
        req.DateStart = Datetime.now().addDays(-1);
        req.StartNumber = '0';

        // ACT
        // Test.startTest()
        GetVehicleOwnersResponseDto res = VehicleOwnersController.getVehicleOwners(req);
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(res));
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    public static void getVehicleOwnersTestService()
    {
        // ARRANGE
        // Set Mock Because some trigger from a different region makes a web service callout
        Test.setMock(HttpCalloutMock.class, new VISTAAssetHandoverMockCallout(true));

        // setup data
        Role__c role = TestClass_AssetRoleCreator.Create(VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER);
        role = [SELECT Account__r.Country_ISO_Code__c, Account__c, Contact__c, Account__r.PersonContactId, Vehicle__c FROM Role__c];
        role.Contact__c = role.Account__r.PersonContactId;
        role.Account__r.Country_ISO_Code__c = Constants.COUNTRY_CODE_AU;
        role.Account__r.BillingStreet = '1351 Test St';
        role.Account__r.ShippingStreet = '1351 Test St';
        role.Account__r.Vehicle_Owner_Date_Last_Changed__c = Datetime.now().addMonths(1);
        Test.startTest(); // This is Joe's solution to the too many soql problem (move Test.startTest() to the wrong spot)
        RDA__c rda = TestClass_RDACreater.CreateRDA(TestClass_OpportunityCreator.generateOpportunity().Id, TestClass_AccountCreator.GenerateCorporateAccount().Id, role.Account__c, role.Vehicle__c);
        update role.Account__r;
        update role;
        // setup request
        GetVehicleOwnersRequestDto req = new GetVehicleOwnersRequestDto();
        req.DateStart = Datetime.now().addDays(-1);
        req.StartNumber = '0';

        RestContext.response = new RestResponse();
        RestContext.request = new RestRequest();
        RestContext.request.params.put('dateStart', String.valueOf(req.DateStart));
        RestContext.request.params.put('startNumber', req.StartNumber);

        // ACT
        // Test.startTest()
        GetVehicleOwnersResponseDto res = VehicleOwnersService.getVehicleOwners();
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(res));
        System.assertEquals(1, res.Data.size());
    }

    @IsTest
    public static void LastChangeDateFunctionsSet()
    {
        Account acc = TestClass_AccountCreator.createPersonAccount_Australia();
        VehicleOwnersController.UpdateImportantInfoHasChangedOnAccount(new List<Account>{ acc }, new Map<Id, Account> { acc.Id => acc });
        Contact contact = [
                SELECT
                        Name,
                        FirstName,
                        LastName,
                        Title,
                        Account.BillingStreet,
                        Account.BillingCity,
                        Account.BillingState,
                        Account.BillingPostalCode,
                        Account.BillingCountry,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingPostalCode,
                        MailingCountry,
                        Email,
                        Email2__c,
                        Email3__c,
                        Account.Name,
                        HomePhone,
                        MobilePhone
                FROM Contact
        ];
        VehicleOwnersController.UpdateImportantInfoHasChangedOnContact(new List<Contact>{ contact }, new Map<Id, Contact> { contact.Id => contact });
    }


    /*
    @IsTest
    public static void updateVehicleOwnerNewOwnership()
    {
        // ARRANGE
        Account currentOwner = TestClass_AccountCreator.createPersonAccount_Australia();
        Account newOwner = TestClass_AccountCreator.createPersonAccount_Australia();

        Asset asset = TestClass_AssetBuilder.BuildAndInsertVehicle();
        asset.VIN__c = 'SAJAB4AV2JCP34186';
        update asset;

        Account dealer = TestClass_AccountCreator.CreateRetailer();
        dealer.Dealer_CI_Code__c = '01000';
        dealer.Dealer_CI_Code_2__c = '01000';
        update dealer;
		Test.startTest();
        Role__c role = TestClass_AssetRoleCreator.Create(VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER, currentOwner.Id, asset.Id);
        UpdateVehicleOwnersAttributeDto attributeDto = UpdateVehicleOwnersAttributeDto.generateTestData();
        attributeDto.ContactEmail = newOwner.PersonEmail;
        attributeDto.VehicleIdentificationNumber = asset.VIN__c;
        attributeDto.DealerCode = '1000';
        UpdateVehicleOwnersResourceDto resourceDto = new UpdateVehicleOwnersResourceDto();
        resourceDto.Attributes = attributeDto;
        resourceDto.OwnershipType = UpdateVehicleOwnersResourceDto.OwnerType.NewOwner;
        UpdateVehicleOwnersRequestDto request = new UpdateVehicleOwnersRequestDto();
        request.Data = new List<UpdateVehicleOwnersResourceDto> { resourceDto };

        // ACT
        UpdateVehicleOwnersResponseDto response = VehicleOwnersController.updateVehicleOwner(request);
        Test.stopTest();
        // ASSERT
        System.debug(JSON.serialize(response));
        Contact personContact = [SELECT Id,AccountId  FROM Contact WHERE AccountId = :newOwner.Id];
        List<Role__c> newOwnerRoles = [SELECT Id From Role__c WHERE Account__c = :newOwner.Id AND Contact__c = :personContact.Id];
        System.assertEquals(true, response.IsSuccess);
    }

    @IsTest
    public static void updateVehicleOwnerEndOfOwnership()
    {
        // ARRANGE
        Account currentOwner = TestClass_AccountCreator.createPersonAccount_Australia();

        Asset asset = TestClass_AssetBuilder.BuildAndInsertVehicle();
        asset.VIN__c = 'SAJAB4AV2JCP34186';
        update asset;

        Account dealer = TestClass_AccountCreator.CreateRetailer();
        dealer.Dealer_CI_Code__c = '01000';
        dealer.Dealer_CI_Code_2__c = '01000';
        update dealer;

        Role__c role = TestClass_AssetRoleCreator.Create(VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER, currentOwner.Id, asset.Id);

        UpdateVehicleOwnersAttributeDto attributeDto = UpdateVehicleOwnersAttributeDto.generateTestData();
        attributeDto.VehicleIdentificationNumber = asset.VIN__c;
        attributeDto.DealerCode = '1000';
        UpdateVehicleOwnersResourceDto resourceDto = new UpdateVehicleOwnersResourceDto();
        resourceDto.Attributes = attributeDto;
        resourceDto.OwnershipType = UpdateVehicleOwnersResourceDto.OwnerType.EndOfOwnership;
        UpdateVehicleOwnersRequestDto request = new UpdateVehicleOwnersRequestDto();
        request.Data = new List<UpdateVehicleOwnersResourceDto> { resourceDto };

        // ACT
        Test.startTest();
        UpdateVehicleOwnersResponseDto response = VehicleOwnersController.updateVehicleOwner(request);
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(response));
        List<Role__c> newOwnerRoles = [SELECT Id From Role__c WHERE Role__c = :VehicleOwnersController.ASSET_ROLE_CURRENT_OWNER AND Role__c.Account__c = :currentOwner.Id];
        System.assertEquals(0, newOwnerRoles.size());
        System.assertEquals(true, response.IsSuccess);
    }
    */
}