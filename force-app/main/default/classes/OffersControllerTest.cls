/**
 * Created by caleb@argologic.com.au on 15/01/2020.
 */

@IsTest
public with sharing class OffersControllerTest
{
    @IsTest
    public static void searchCorporateOffersTest()
    {
        // ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        corpPartner.NSC_Supported__c = true;
        update corpPartner;
        TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, corpPartner.Id, 10);
        GetCorporatePartnerOffersRequest req = new GetCorporatePartnerOffersRequest();
        req.VariantId = ass.Derivative__c;
        req.SearchKey = corpPartner.Name;

        // ACT
        Test.startTest();
        GetCorporatePartnerOffersResponseDto res = OffersController.searchCorporateOffers(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        System.assertEquals(10, res.Data.size());
    }

    @IsTest
    public static void getTest()
    {
        // ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        // generate complimentary offer
        TestClass_OfferBuilder.createComplimentaryOffers(ass.Derivative__c, 1);
        // generate corp offer where corpPartner does match request
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        corpPartner.NSC_Supported__c = true;
        update corpPartner;
        TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, corpPartner.Id, 1);
        // generate corp offer where corpPartner does not match request
        Account corpPartner2 = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        corpPartner2.NSC_Supported__c = true;
        update corpPartner2;
        TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, corpPartner2.Id, 1);

        GetOffersRequestDto req = new GetOffersRequestDto();
        req.VariantId = ass.Derivative__c;
        req.typeNames = new List<String> { 'Corporate', 'Complimentary' };
        req.CorporatePartnerId = corpPartner.Id;

        // ACT
        Test.startTest();
        GetOffersResponseDto res = OffersController.get(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
        // should be 2 offers the complimentary one and one of the corp ones
        System.assertEquals(2, res.Data.size());
    }

    @IsTest
    public static void getComplimentaryServicePlanOfferTest()
    {
        // ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        TestClass_OfferBuilder.createComplimentaryOffers(ass.Derivative__c, 1);

        // ACT
        Test.startTest();
        Offers__c res = OffersController.getComplimentaryServicePlanOffer(ass.Derivative__c);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
    }

    @IsTest
    public static void getCorporateServicePlanOfferTest()
    {
        // ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account corpPartner = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        corpPartner.NSC_Supported__c = true;
        update corpPartner;
        TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, corpPartner.Id, 10);

        // ACT
        Test.startTest();
        Offers__c res = OffersController.getCorporateServicePlanOffer(ass.Derivative__c, corpPartner.Id);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
    }

    @IsTest
    public static void buildOpportunityLineItemResourceDtoTest()
    {

        // ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        TestClass_OfferBuilder.createComplimentaryOffers(ass.Derivative__c, 1);
        Offers__c offer = OffersController.getComplimentaryServicePlanOffer(ass.Derivative__c);
        offer.Service_Plan_Product2Id__c = ass.Derivative__c;
        update offer;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook('Test Book');
        PricebookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(ass.Derivative__c, pb);
        Opportunity opp = TestClass_OpportunityCreator.generateOpportunity();

        // ACT
        Test.startTest();
        List<OpportunityLineItemResourceDto> res = OffersController.buildOpportunityLineItemResourceDto(new List<Offers__c> { offer }, opp.Id, pb.Id);
        Test.stopTest();

        // ASSERT
        //System.assertEquals(1, res.size());
        System.assertNotEquals(null, res);
    }

    @IsTest
    public static void searchCorporatePartnersTest() {
        // ARRANGE
        Asset ass = TestClass_AssetBuilder.BuildAndInsertVehicle();
        Account acc = TestClass_AccountCreator.GenerateCorporateAccountAustralia();
        acc.NSC_Supported__c = true;
        update acc;
        TestClass_OfferBuilder.createCorporateOffersList(ass.Derivative__c, acc.Id, 2);

        GetCorporatePartnersRequest req = new GetCorporatePartnersRequest();
        req.SearchKey = 'Test';
        // ACT
        Test.startTest();
        GetCorporatePartnersResponseDto res = OffersController.searchCorporatePartners(req);
        Test.stopTest();

        // ASSERT
    }
}