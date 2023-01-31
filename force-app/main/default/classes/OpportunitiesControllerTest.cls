/**
 * Created by caleb.manning on 2019-08-13.
 */

@IsTest
public class OpportunitiesControllerTest {

    public static List<Opportunity> createOppList() {
        Account acc = TestClass_AccountCreator.createPersonAccount();
        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++)
        {
            Opportunity opp = new Opportunity(
                    ContactId = acc.PersonContactId,
                    Name = 'Test' + i,
                    StageName = 'Negotiation',
                    CloseDate = Date.today().addDays(3),
                    Budget__c = 100000,
                    CurrencyIsoCode = 'JPY',
                    Country_ISO_Code__c = 'AU',
                    AccountId = acc.Id,
                    Purchase_Type__c = 'New Vehicle'
            );
            //Check RecordType
            System.debug('Account Id: ' + acc.Id);
            System.debug('Opp-RecordTypeName: ' + opp.Account.RecordType.Name);
            opps.add(opp);
        }
        insert opps;
        return opps;
    }

    @TestSetup
    static void createTestData() {
        createOppList();
    }

    @IsTest
    private static void getPricebookTest(){
        //ARRANGE
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook ('Australia');

        //ACT
        Test.startTest();
        Id testPb = OpportunitiesController.getPricebook2Id();
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, testPb);
    }

    public static GetServicePlansRequestDto generateGetServicePlansRequestDto() {

        Product2 derivative = TestClass_AssetBuilder.buildDerivative();
        Id servicePlanId = TestDataFactory.createServicePlan('1000');
        List<Offers__c> offers = TestDataFactory.createOfferList(derivative.Id, servicePlanId);
        GetServicePlansRequestDto req = new GetServicePlansRequestDto(new List<String>{
                'Complimentary'
        }, derivative.Id, servicePlanId);
        req.MaxResults = 10;
        return req;
    }


    private static GetOffersRequestDto generateGetOffersRequestDto() {
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();
        TestDataFactory.createOfferList(derivative.Id);
        return new GetOffersRequestDto(derivative.Id, new List<String>{
                'Complimentary'
        });
    }


    private static SetVariantRequestDto generateSalesVariantRequestDtoWithOpCorporatePartner() {
        // Create an OpportunityLineItemAttributesDto's for every Opportunity
        // Set up SObjects
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Corporate_Partner_Account__c = corpPartner.Id;
        update opp;
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        // Setup Dto
        SetVariantRequestDto req = new SetVariantRequestDto();
        req.OpportunityId = opp.Id;
        req.VariantId = derivative.Id;
        req.Qty = 1;
        req.TotalPrice = 10000;
        req.PricebookEntryId = standardPrice.Id;
        req.TypeNames = new List<String>{
                'Complimentary'
        };
        req.PricebookId = Test.getStandardPricebookId();

        return req;
    }

    public static SetVariantRequestDto generateSalesVariantRequestDto() {
        // Create an OpportunityLineItemAttributesDto's for every Opportunity
        // Set up SObjects
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        // Setup Dto
        SetVariantRequestDto req = new SetVariantRequestDto();
        req.OpportunityId = opp.Id;
        req.VariantId = derivative.Id;
        req.Qty = 1;
        req.TotalPrice = 10000;
        req.PricebookEntryId = standardPrice.Id;
        req.TypeNames = new List<String>{
                'Complimentary'
        };
        req.PricebookId = Test.getStandardPricebookId();

        return req;
    }

    @IsTest
    private static void createTest_Negative() {
        //ARRANGE
        CreateOpportunityRequestDto request = new CreateOpportunityRequestDto();
        CreateOpportunityResponseDto response = null;

        //ACT
        Test.startTest();
        response = OpportunitiesController.create(request);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
    }

    @IsTest
    private static void setAssetTest_Negative() {
        //ARRANGE
        SetOpportunityAssetRequestDto request = new SetOpportunityAssetRequestDto();
        request.OpportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Exception ex = null;
        SetOpportunityAssetResponseDto response = null;

        //ACT
        try {
            response = OpportunitiesController.setAsset(request);
        } catch (Exception e) {
            ex = e;
        }

        //ASSERT
        System.assertNotEquals(null, response);
        System.assertEquals(null, ex);
    }

    /**
    @IsTest
    private static void setOpportunityCorporatePartnerTest() {
        //ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        SetCorporatePartnerRequestDto request = new SetCorporatePartnerRequestDto();
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        request.CorporatePartnerId = corpPartner.Id;
        request.OpportunityId = op.Id;

        Exception myException = null;
        SetCorporatePartnerResponseDto response = null;

        //ACT
        Test.startTest();
        try {
            response = OpportunitiesController.setOpportunityCorporatePartner(request);
        } catch (Exception e) {
            myException = e;
        }
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
        System.assertEquals(null, myException);
    }


    @IsTest
    private static void setOpportunityCorporatePartnerTest2() {
        //ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        SetCorporatePartnerRequestDto request = new SetCorporatePartnerRequestDto();
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        op.Corporate_Partner_Account__c = corpPartner.Id;
        update op;

        request.CorporatePartnerId = corpPartner.Id;
        request.OpportunityId = op.Id;

        Exception myException = null;
        SetCorporatePartnerResponseDto response = null;

        //ACT
        Test.startTest();
        try {
            response = OpportunitiesController.setOpportunityCorporatePartner(request);
        } catch (Exception e) {
            myException = e;
        }
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
        System.assertEquals(null, myException);
    }
**/

    @IsTest
    private static void setServicePlanTest() {
        //ARRANGE
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook ('Australia');
        Product2 car = TestClass_AssetBuilder.buildDerivativeAustralia();
        Product2 plan = new Product2();
        plan.RecordTypeId = RecordTypeUtility.getRecordTypeId_Product2_Service_Plan();
        //plan.Derivative__c = car.Model_Vehicle_Spec__c;
        plan.Name = 'My Plan';
        insert plan;

        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id = Test.getStandardPricebookId();
        pbe1.UnitPrice = 100;
        pbe1.Product2Id = car.Id;
        insert pbe1;

        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.UnitPrice = 100;
        pbe.Product2Id = car.Id;
        insert pbe;



        SetServicePlanRequestDto request = new SetServicePlanRequestDto();
        request.OpportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        request.PricebookId = pb.Id;
        request.TypeNames  = new List<String>{'Retail'};
        request.ServicePlanId = plan.Id;
        request.PricebookEntryId = pbe.Id;
        request.Qty = 1;
        request.ServicePlanType = 'Retail';


        //ACT
        Test.startTest();
        SetServicePlanResponseDto response = OpportunitiesController.setServicePlan(request);
        Test.stopTest();

//ASSERT
        System.assertNotEquals(null, response);

    }

    @IsTest
    private static void getMilestonesTest() {
//ARRANGE
        Opportunity op = [SELECT Id FROM Opportunity WHERE IsClosed = FALSE LIMIT 1];
        GetOpportunityMilestonesRequestDto request = new GetOpportunityMilestonesRequestDto();
        request.OpportunityId = op.Id;

//ACT
        Test.startTest();
        GetOpportunityMilestonesResponseDto response = OpportunitiesController.getMilestones(request);
        Test.stopTest();

//ASSERT
        System.assertNotEquals(null, response);
    }

    @IsTest
    static void getSaleTypesTest() {
        Test.startTest();
        List <SaleDto> dtos = OpportunitiesController.getSaleTypes();
        Test.stopTest();
        System.assertNotEquals(dtos, null);
        System.assertNotEquals(dtos[0].Attributes.Name, null);
        System.assertNotEquals(dtos[0].Id, null);
    }

    @IsTest
    static void getOpportunities_Test_Positive() {
//ARRANGE
        Product2 derivative = TestClass_AssetBuilder.buildDerivativeAustralia();
        derivative = [SELECT Id, Make__c, Model_Vehicle_Spec__r.Make__c, Model__c FROM Product2 WHERE Id = :derivative.Id];
        derivative.Model_Vehicle_Spec__r.Make__c = derivative.Make__c;
        update derivative.Model_Vehicle_Spec__r;

        TestClass_PricebookCreator.CreatePricebook('Australia');

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        createOppList();
        List<Opportunity> opps = [SELECT Id From Opportunity LIMIT 2];
        for (Opportunity opp : opps)
        {
            opp.Brand__c = derivative.Make__c;
            opp.Pricebook2Id = standardPrice.Pricebook2Id;
        }
        update opps;

        Account acc = TestClass_AccountCreator.BuildRetailer();
        insert acc;

        Test.startTest();
        Asset ass = new Asset();
        ass.VIN__c = 'snosdonrir';
        ass.Name = 'snosdonrir';
        ass.Brand__c = derivative.Make__c;
        ass.Model__c = derivative.Model__c;
        ass.Derivative__c = derivative.Id;
        ass.AccountId = acc.Id;
        insert ass;


        DeleteOpportunityProductDto req = new DeleteOpportunityProductDto();
        req.OpportunityId = opps[0].Id;
        req.DoDeleteAsset = true;
        req.DoDeleteProduct = true;
        req.DoDeleteServicePlan = false;


        ProductsController.setVariant(opps[0].Id, derivative.Id);
        AssetsController.SetAssetWithMultiAssignCheck(opps[0].Id, ass.Id);
        OpportunitiesController.getOpportunityData(opps[0].Id);
        Test.stopTest();

    }

    @IsTest
    static void updateOpportunity_Test_Negative_MissingOpportunityId() {
//ARRANGE
        UpdateOpportunityRequestDto request = new UpdateOpportunityRequestDto();
        UpdateOpportunityResponseDto response = null;
        Exception ex = null;

//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.updateOpportunity(request);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, ex);
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.Errors);
        System.assertEquals(1, response.Errors.size());
        System.assertEquals(false, response.IsSuccess);
    }

    @IsTest
    static void updateOpportunity_Test_SaleType_New() {
//ARRANGE
        UpdateOpportunityRequestDto request = new UpdateOpportunityRequestDto();
        UpdateOpportunityResponseDto response = null;
        Exception ex = null;
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        request.OpportunityId = op.Id;
        request.SaleType = 'new';

//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.updateOpportunity(request);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, ex);
        System.assertNotEquals(null, response);

    }

    @IsTest
    static void updateOpportunity_Test_SaleType_Demo() {
//ARRANGE
        UpdateOpportunityRequestDto request = new UpdateOpportunityRequestDto();
        UpdateOpportunityResponseDto response = null;
        Exception ex = null;
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        request.OpportunityId = op.Id;
        request.SaleType = 'demo';

//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.updateOpportunity(request);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, ex);
        System.assertNotEquals(null, response);

    }

    @IsTest
    static void updateOpportunity_Test_SaleType_APO() {
//ARRANGE
        UpdateOpportunityRequestDto request = new UpdateOpportunityRequestDto();
        UpdateOpportunityResponseDto response = null;
        Exception ex = null;
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        request.OpportunityId = op.Id;
        request.SaleType = 'approved_pre_owned';

//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.updateOpportunity(request);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, ex);
        System.assertNotEquals(null, response);

    }

    @IsTest
    static void updateOpportunity_Test_SaleType_PreOwned() {
//ARRANGE
        UpdateOpportunityRequestDto request = new UpdateOpportunityRequestDto();
        UpdateOpportunityResponseDto response = null;
        Exception ex = null;
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        request.OpportunityId = op.Id;
        request.SaleType = 'pre-owned';

//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.updateOpportunity(request);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, ex);
        System.assertNotEquals(null, response);
    }



    @IsTest
    static void updateOpportunity_Test_Negative_BadSaleType() {
//ARRANGE
        UpdateOpportunityRequestDto request = new UpdateOpportunityRequestDto();
        UpdateOpportunityResponseDto response = null;
        Exception ex = null;
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        request.OpportunityId = op.Id;
        request.SaleType = 'BadSaleType';

//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.updateOpportunity(request);
        } catch (Exception e) {
            ex = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, ex);
        System.assertNotEquals(null, response);
        System.assertNotEquals(null, response.Errors);
        System.assertEquals(1, response.Errors.size());
        System.assertEquals(false, response.IsSuccess);
    }

    @IsTest
    static void sendOpportunityToDms_TestPositive() {

//ARRANGE
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];

        SyncOpportunityToDmsRequestDto request = new SyncOpportunityToDmsRequestDto();
        request.OpportunityId = op.Id;


//ACT
        Test.startTest();
        SyncOpportunityToDmsResponseDto response = OpportunitiesController.sendOpportunityToDms(request);
        Test.stopTest();

//ASSERT
        System.assertNotEquals(null, response);

    }

    @IsTest
    static void sendOpportunityToDms_Test_Negative_MissingOpportunityId() {

//ARRANGE
        SyncOpportunityToDmsRequestDto request = new SyncOpportunityToDmsRequestDto();
        SyncOpportunityToDmsResponseDto response = null;
        Exception myEx = null;


//ACT
        Test.startTest();
        try {
            response = OpportunitiesController.sendOpportunityToDms(request);
        } catch (Exception e) {
            myEx = e;
        }
        Test.stopTest();

//ASSERT
        System.assertEquals(null, myEx);
        System.assertNotEquals(null, response.Errors);
        System.assertEquals(1, response.Errors.size());

    }

    @IsTest
    static void setVariantTest() {
// ARRANGE
        SetVariantRequestDto req = generateSalesVariantRequestDto();

// ACT
        Test.startTest();
        SetVariantResponseDto res = OpportunitiesController.setVariant(req);
        Test.stopTest();

// ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.debug(JSON.serialize(res));
    }

    @IsTest
    static void setVariantWithCorporatePartnerTest() {
// ARRANGE
        SetVariantRequestDto req = generateSalesVariantRequestDtoWithOpCorporatePartner();

// ACT
        Test.startTest();
        SetVariantResponseDto res = OpportunitiesController.setVariant(req);
        Test.stopTest();

// ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.debug(JSON.serialize(res));
    }

    @IsTest
    static void getOffersTest() {
// ARRANGE
        GetOffersRequestDto req = generateGetOffersRequestDto();
        System.debug('Inserted Offers = ' + JSON.serialize([SELECT Id, Type__c, Derivative_Product2Id__c FROM Offers__c]));
        System.debug(req.VariantId);

// ACT
        Test.startTest();
        GetOffersResponseDto res = OpportunitiesController.getOffers(req);
        Test.stopTest();

// ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.debug(JSON.serialize(res));
    }

    @IsTest
    static void getServicePlansTest() {
// ARRANGE
        Opportunity op = [SELECT Id FROM Opportunity LIMIT 1];
        GetServicePlansRequestDto req = generateGetServicePlansRequestDto();
        req.OpportunityId = op.Id;
        Product2 prod = TestClass_AssetBuilder.buildDerivativeAustralia();


// ACT
        Test.startTest();
        GetServicePlansResponseDto servicePlans = OpportunitiesController.getServicePlans(req);
        Test.stopTest();

// ASSERT
        System.assertNotEquals(null, servicePlans);
        System.assertNotEquals(null, servicePlans.Data);
//System.assertEquals(1, servicePlans.Data.size());
        System.debug(JSON.serialize(servicePlans));

    }

    @IsTest
    private static void closeMilestoneOpportunityTest() {
        /*
        //ARRANGE
        CloseOpportunityRequestDto request = new CloseOpportunityRequestDto();
        Opportunity opp = [SELECT Id, Retailer_Loss_Category__c FROM Opportunity WHERE IsClosed = FALSE LIMIT 1];
        opp.Retailer_Loss_Category__c = 'bla bla bla';
        update opp;
        request.OpportunityId = opp.Id;
        request.LostDescription = 'xxx';
        request.LostReason = 'xxx';
        request.OpportunityStage = 'Lost';
        request.PlanedHandoverDate = String.valueOf(Date.today());
        CloseOpportunityResponseDto response = null;

        //ACT
        Test.startTest();
        response = OpportunitiesController.closeMilestoneOpportunity(request);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
         */
    }


    @IsTest
    private static void closeMilestoneOpportunityTest1() {
        //ARRANGE
        Product2 derivative = TestClass_AssetBuilder.buildDerivativeAustralia();
        derivative = [SELECT Id, Make__c, Model_Vehicle_Spec__r.Make__c, Model__c FROM Product2 WHERE Id = :derivative.Id];
        derivative.Model_Vehicle_Spec__r.Make__c = derivative.Make__c;
        update derivative.Model_Vehicle_Spec__r;

        TestClass_PricebookCreator.CreatePricebook('Australia');

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        List<Opportunity> opps = createOppList();
        for (Opportunity opp : opps)
        {
            opp.Country_ISO_Code__c = 'AU';
            opp.Brand__c = derivative.Make__c;
            opp.Pricebook2Id = standardPrice.Pricebook2Id;
        }
        update opps;

        Account acc = TestClass_AccountCreator.BuildRetailer();
        insert acc;

		Test.startTest();
        Asset ass = new Asset();
        ass.VIN__c = 'snosdonrir';
        ass.Name = 'snosdonrir';
        ass.Brand__c = derivative.Make__c;
        ass.Model__c = derivative.Model__c;
        ass.Derivative__c = derivative.Id;
        ass.AccountId = acc.Id;
        insert ass;

        
        ProductsController.setVariant(opps[0].Id, derivative.Id);

        CloseOpportunityRequestDto request = new CloseOpportunityRequestDto();
        request.OpportunityId = opps[0].Id;
        request.LostDescription = 'xxx';
        request.LostReason = 'xxx';
        request.OpportunityStage = 'Won';
        request.PlanedHandoverDate = String.valueOf(Date.today());
        CloseOpportunityResponseDto response = null;

        //ACT

        response = OpportunitiesController.closeMilestoneOpportunity(request);
        Test.stopTest();

        //ASSERT
        System.assertNotEquals(null, response);
    }

    @IsTest
    private static void GetMilestoneOpportunityInfoTest2()
    {
        // ARRANGE
        GetOpportunityInfoRequestDto request = new GetOpportunityInfoRequestDto();

        // ACT
        Test.startTest();
        GetOpportunityInfoResponseDto response = OpportunitiesController.GetMilestoneOpportunityInfo(request);
        Test.stopTest();

        // ASSERT
        System.assertEquals(response.Errors.size(), 1);
    }

    @IsTest
    private static void GetMilestoneOpportunityInfoTest3()
    {
        // ARRANGE
        GetOpportunityInfoRequestDto request = new GetOpportunityInfoRequestDto();
        request.OpportunityId = [SELECT Id FROM Opportunity WHERE IsClosed = FALSE LIMIT 1].Id;

        // ACT
        Test.startTest();
        GetOpportunityInfoResponseDto response = OpportunitiesController.GetMilestoneOpportunityInfo(request);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, response);
    }

    @IsTest
    public static void DeleteOpportunityProductTest()
    {
        Product2 derivative = TestClass_AssetBuilder.buildDerivativeAustralia();
        derivative = [SELECT Id, Make__c, Model_Vehicle_Spec__r.Make__c, Model__c FROM Product2 WHERE Id = :derivative.Id];
        derivative.Model_Vehicle_Spec__r.Make__c = derivative.Make__c;
        update derivative.Model_Vehicle_Spec__r;

        TestClass_PricebookCreator.CreatePricebook('Australia');

        PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(), Product2Id = derivative.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'JPY', IsActive = true);
        insert standardPrice;

        createOppList();
        List<Opportunity> opps = [SELECT Id From Opportunity LIMIT 2];
        for (Opportunity opp : opps)
        {
            opp.Brand__c = derivative.Make__c;
            opp.Pricebook2Id = standardPrice.Pricebook2Id;
        }
        update opps;

        Account acc = TestClass_AccountCreator.BuildRetailer();
        insert acc;

        Test.startTest();
        Asset ass = new Asset();
        ass.VIN__c = 'snosdonrir';
        ass.Name = 'snosdonrir';
        ass.Brand__c = derivative.Make__c;
        ass.Model__c = derivative.Model__c;
        ass.Derivative__c = derivative.Id;
        ass.AccountId = acc.Id;
        insert ass;


        DeleteOpportunityProductDto req = new DeleteOpportunityProductDto();
        req.OpportunityId = opps[0].Id;
        req.DoDeleteAsset = true;
        req.DoDeleteProduct = true;
        req.DoDeleteServicePlan = false;


        //ProductsController.setVariant(opps[0].Id, derivative.Id);
        AssetsController.SetAssetWithMultiAssignCheck(opps[0].Id, ass.Id);

        OpportunitiesController.deleteOpportunityProduct(req);
        Test.stopTest();
    }
}