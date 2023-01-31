/**
 * Created by caleb on 10/09/2019.
 */

@IsTest
public with sharing class AssetsControllerTest {
    public static final String ASSET_TEST_STATUS = 'Created';
    public static final Integer NUMBER_OF_TEST_ASSETS = 10;

    @IsTest
    private static CreateAssetRequestDto generateCreateAssetRequestDto() {

        Product2 derivative = TestClass_AssetBuilder.buildDerivative();
        CreateAssetRequestDto req = new CreateAssetRequestDto();
        req.derivativeProduct2Id = derivative.Id;
        req.currencyIsoCode = 'GBP';
        req.assetRecordType = 'Vehicle';
        req.name = 'Test Asset';
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        req.accountId = acc.Id;
        return req;
    }
    private static Account buildAccount() {
        Account a = new Account(Name = 'Test Account Name');
        insert a;
        return a;
    }
    private static User buildUser(Account acc) {


        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = acc.Id);
        c.Email = 'myemail@yahoo.com';
        insert c;

        User user = new User();
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Dealer Principle'].Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'nobodyUknow@happy.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = c.Id;
		System.RunAs(new User(Id=userinfo.getUserId())){
        insert user;
        }
        return user;
    }
    private static GetAssetsRequestDto buildGetAssetsRequest(User user, Account acc) {

        Product2 car = TestClass_AssetBuilder.buildDerivative();

        TestClass_AssetBuilder.createAssetList(NUMBER_OF_TEST_ASSETS, acc.Id, car);
        GetAssetsRequestDto req = new GetAssetsRequestDto();
        req.UserId = user.Id;
        req.DerivativeProduct2Id = car.Id;
        return req;
    }

    @IsTest
    public static void getAssetListTestNew() {
        // ARRANGE
        Account acc = buildAccount();
        User user = buildUser(acc);        
        GetAssetsRequestDto req = buildGetAssetsRequest(user, acc);
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_NEW;
        //req.Statuses = new Set<String>{ ASSET_TEST_STATUS };


        GetAssetsResponseDto res = null;

        // ACT

        Test.startTest();
        System.RunAs(user) {
            res = AssetsController.getAssetList(req);
        }
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
//        for (AssetResourceDto ass : res.Data) {
//            System.assertEquals(ASSET_TEST_STATUS, ass.Attributes.Status);
//        }
        System.debug(JSON.serialize(res));

    }

    @IsTest
    public static void getAssetListTestNewNoProductId() {
        // ARRANGE
        Account acc = buildAccount();
        User user = buildUser(acc);
        GetAssetsRequestDto req = buildGetAssetsRequest(user, acc);
        req.DerivativeProduct2Id = null;
        req.SearchKey = 'xxx';
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_NEW;
        //req.Statuses = new Set<String>{ ASSET_TEST_STATUS };


        GetAssetsResponseDto res = null;

        // ACT

        Test.startTest();
        System.RunAs(user) {
            res = AssetsController.getAssetList(req);
        }
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
//        for (AssetResourceDto ass : res.Data) {
//            System.assertEquals(ASSET_TEST_STATUS, ass.Attributes.Status);
//        }
        System.debug(JSON.serialize(res));

    }


    @IsTest
    public static void getAssetListTestDemo() {
        // ARRANGE
        Account acc = buildAccount();
        User user = buildUser(acc);
        GetAssetsRequestDto req = buildGetAssetsRequest(user, acc);
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_PRE_OWNED;
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_APPROVED_PRE_OWNED;
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_DEMO;
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_DEMONSTRATOR;

        //req.Statuses = new Set<String>{ ASSET_TEST_STATUS };

        Test.startTest();
        GetAssetsResponseDto res = new GetAssetsResponseDto();
        // ACT


        System.RunAs(user) {
            res = AssetsController.getAssetList(req);
        }
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
//        for (AssetResourceDto ass : res.Data) {
//            System.assertEquals(ASSET_TEST_STATUS, ass.Attributes.Status);
//        }
        System.debug(JSON.serialize(res));

    }

    @IsTest
    public static void getAssetListTestPreOwned() {
        // ARRANGE
        Account acc = buildAccount();
        User user = buildUser(acc);
        GetAssetsRequestDto req = buildGetAssetsRequest(user, acc);
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_PRE_OWNED;

        //req.Statuses = new Set<String>{ ASSET_TEST_STATUS };

        Test.startTest();
        GetAssetsResponseDto res = new GetAssetsResponseDto();
        // ACT


        System.RunAs(user) {
            res = AssetsController.getAssetList(req);
        }
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
//        for (AssetResourceDto ass : res.Data) {
//            System.assertEquals(ASSET_TEST_STATUS, ass.Attributes.Status);
//        }
        System.debug(JSON.serialize(res));

    }

    @IsTest
    public static void getAssetListTestApprovedPreOwned() {
        // ARRANGE
        Account acc = buildAccount();
        User user = buildUser(acc);
        GetAssetsRequestDto req = buildGetAssetsRequest(user, acc);
        req.SaleType = GetAssetsRequestDto.SALE_TYPES_APPROVED_PRE_OWNED;

        //req.Statuses = new Set<String>{ ASSET_TEST_STATUS };

        Test.startTest();
        GetAssetsResponseDto res = new GetAssetsResponseDto();
        // ACT


        System.RunAs(user) {
            res = AssetsController.getAssetList(req);
        }
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
//        for (AssetResourceDto ass : res.Data) {
//            System.assertEquals(ASSET_TEST_STATUS, ass.Attributes.Status);
//        }
        System.debug(JSON.serialize(res));

    }

    @IsTest
    public static void createAssetTest() {
        // ARRANGE
        CreateAssetRequestDto req = generateCreateAssetRequestDto();

        // ACT
        Test.startTest();
        CreateAssetResponseDto res = AssetsController.createAsset(req);
        Test.stopTest();

        // ASSERT
        System.debug(JSON.serialize(res));
        System.assertNotEquals(null, res);
        Asset CreatedAsset = [SELECT Id, Model__c, Derivative__c, Brand__c, AccountId, CurrencyIsoCode FROM Asset WHERE Id = :res.AssetId];
        System.assertNotEquals(null, CreatedAsset);
        System.assertEquals(CreatedAsset.Id, res.AssetId);
        System.debug(JSON.serialize(CreatedAsset));

    }

    @IsTest(SeeAllData=true)
    public static void emailLogicTest()
    {
        OpportunityProductTriggerHandler.skipLogic = true;

        Product2 derivative = TestClass_AssetBuilder.buildDerivativeAustralia();
        derivative = [SELECT Id, Make__c, Model_Vehicle_Spec__r.Make__c, Model__c FROM Product2 WHERE Id = :derivative.Id];
        derivative.Model_Vehicle_Spec__r.Make__c = derivative.Make__c;
        update derivative.Model_Vehicle_Spec__r;

        //TestClass_PricebookCreator.CreatePricebook('Australia');

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        List<Opportunity> opps = TestClass_OpportunityCreator.createOppList();
        for (Opportunity opp : opps)
        {
            opp.Brand__c = derivative.Make__c;
            opp.Pricebook2Id = standardPrice.Pricebook2Id;
        }
        update opps;

        Account acc = TestClass_AccountCreator.BuildRetailer();
        insert acc;


        Asset ass = new Asset();
        ass.VIN__c = 'snosdonrir';
        ass.Name = 'snosdonrir';
        ass.Brand__c = derivative.Make__c;
        ass.Model__c = derivative.Model__c;
        ass.Derivative__c = derivative.Id;
        ass.AccountId = acc.Id;
        insert ass;


        //ProductsController.setVariant(opps[0].Id, derivative.Id);
        AssetsController.SetAssetWithMultiAssignCheck(opps[0].Id, ass.Id);

        Test.startTest();

        opps[0].StageName = 'Won';
        update opps[0];
        ProductsController.setVariant(opps[1].Id, derivative.Id);
        AssetsController.SetAssetWithMultiAssignCheck(opps[1].Id, ass.Id);

        AssetsController.SetAssetForced(opps[1].Id, ass.Id, false);
        Test.stopTest();
    }
    
    @IsTest
    public static void CoverageTest()
    {
        AssetsController.TestCoverage();
    }
}