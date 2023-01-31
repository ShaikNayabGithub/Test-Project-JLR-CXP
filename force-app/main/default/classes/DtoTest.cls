/**
 * Created by GrantMillgate-EasyTe on 2020-03-04.
 */
@IsTest
public with sharing class DtoTest{
    @IsTest
    public static void buildServicePlanFromPbeTest() {

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
        ServicePlanResourceDto dto = new ServicePlanResourceDto(pbe);

    }

    @IsTest
    public static void buildServicePlanFromOfferTest(){
        OfferResourceDto dto = new OfferResourceDto();
        dto.Attributes.ServicePlanType = '';
        dto.Attributes.CorporatePartnerId = '';
        dto.Attributes.CorporatePartnerName = '';
        dto.Attributes.DateEnd = '';
        dto.Attributes.DateStart = '';
        dto.Attributes.DiscountAmount = 0;
        dto.Attributes.DiscountPercentage = 0;
        dto.Attributes.MinimumPurchasePrice = 0;
        dto.Attributes.Name = '';
        dto.Attributes.QantasPoints = 0;
        dto.Attributes.ServicePlanName = '';
        ServicePlanResourceDto plan = new ServicePlanResourceDto(dto);
    }

    @IsTest
    public static void buildServicePlanTest(){

    ServicePlanResourceDto plan = buildServicePlanResourceDto();

    }


    public static ServicePlanResourceDto buildServicePlanResourceDto(){
        ServicePlanResourceDto dto = new ServicePlanResourceDto();
        dto.Attributes.ServicePlanType = '';
        dto.Attributes.PricebookEntryId = '';
        dto.Attributes.UnitPrice = '';
        dto.Attributes.OpportunityId = '';
        dto.Attributes.CorporatePartnerId = '';
        dto.Attributes.CorporatePartnerName = '';
        dto.Attributes.DateEnd = '';
        dto.Attributes.DateStart = '';
        dto.Attributes.DiscountAmount = 0;
        dto.Attributes.DiscountPercentage = 0;
        dto.Attributes.Kilometers = 0;
        dto.Attributes.MinimumPurchasePrice = 0;
        dto.Attributes.Months = 0;
        dto.Attributes.Name = '';
        dto.Attributes.QantasPoints = 0;
        dto.Attributes.ServicePlanName = '';
        return dto;
    }

    @IsTest
    public static void buildOpportunityAttributeDto(){
        OpportunityAttributesDto dto = new OpportunityAttributesDto();
        dto.Pricebook2Id = Test.getStandardPricebookId();
        dto.Name = '';
        dto.OpportunityId = '';
        dto.AccountId = '';
        dto.BuyerAccountId = '';
        dto.BuyerAddressCity = '';
        dto.BuyerAddressLine1 = '';
        dto.BuyerAddressLine2 = '';
        dto.BuyerAddressLine3 = '';
        dto.BuyerAddressLine4 = '';
        dto.BuyerAddressPostcode = '';
        dto.BuyerAddressState = '';
        dto.BuyerCompanyName = '';
        dto.BuyerAgeGroup = '';
        dto.BuyerEmailBusiness = '';
        dto.BuyerEmailPersonal = '';
        dto.BuyerNameFirst = '';
        dto.BuyerNameLast = '';
        dto.BuyerNameTitle = '';
        dto.BuyerPhoneHome = '';
        dto.BuyerPhoneMobile = '';
        dto.BuyerPhoneWork = '';
        dto.VehicleUnitPrice = '';
        dto.VehicleBodyStyle = '';
        dto.VehicleAlternateModels = '';
        dto.VehicleBrand = '';
        dto.VehicleCondition = '';
        dto.VehicleDescription = '';
        dto.VehicleEngineType = '';
        dto.VehicleModel = '';
        dto.VehicleModelYear = '';
        dto.VehicleTrim = '';
        dto.CampaignName = '';
        dto.Comments = '';
        dto.ContactType = '';
        dto.DealerCode = '';
        dto.LeadSource = '';
        dto.SaleType = '';
        dto.SaleType = '';
        dto.Notes = '';

    }
}