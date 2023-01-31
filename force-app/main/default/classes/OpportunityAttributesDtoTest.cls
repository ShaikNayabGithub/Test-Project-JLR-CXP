/**
 * Created by caleb@argologic.com.au on 3/08/2020.
 */

@IsTest
public with sharing class OpportunityAttributesDtoTest
{
    @IsTest
    public static void test1()
    {
        OpportunityAttributesDto atts = new OpportunityAttributesDto();

        atts.AccountId = 'tes';
        atts.AccountName = 'tes';
        atts.Stage = 'tes';
        atts.Pricebook2Id = 'tes';
        atts.SystemName = 'tes';
        atts.RequestDateTime = 'tes';
        atts.EnquiryType = 'tes';
        atts.SaleType = 'tes';
        atts.IsMarketingPermitted = false;
        atts.LeadSource = 'tes';
        atts.LeadType = 'tes';
        atts.DealerCode = 'tes';
        atts.CampaignName = 'tes';
        atts.DoDistributeToDealer = false;
        atts.Comments = 'tes';
        atts.Notes = 'tes';
        atts.Status = 'tes';
        atts.ContactType = 'tes';
        atts.OpportunityId = 'tes';
        atts.BuyerAccountId = 'tes';
        atts.BuyerNameTitle = 'tes';
        atts.BuyerNameFirst = 'tes';
        atts.BuyerNameLast = 'tes';
        atts.BuyerAgeGroup = 'tes';
        atts.BuyerCompanyName = 'tes';
        atts.BuyerAddressLine1 = 'tes';
        atts.BuyerAddressLine2 = 'tes';
        atts.BuyerAddressLine3 = 'tes';
        atts.BuyerAddressLine4 = 'tes';
        atts.BuyerAddressCity = 'tes';
        atts.BuyerAddressState = 'tes';
        atts.BuyerAddressPostcode = 'tes';
        atts.BuyerPhoneMobile = 'tes';
        atts.BuyerPhoneWork = 'tes';
        atts.BuyerPhoneHome = 'tes';
        atts.BuyerEmailPersonal = 'tes';
        atts.BuyerEmailBusiness = 'tes';
        atts.VehicleBrand = 'tes';
        atts.VehicleModel = 'tes';
        atts.VehicleBodyStyle = 'tes';
        atts.VehicleModelYear = 'tes';
        atts.VehicleEngineType = 'tes';
        atts.VehicleTrim = 'tes';
        atts.VehicleDescription = 'tes';
        atts.VehicleCondition = 'tes';
        atts.VehicleAlternateModels = 'tes';
        atts.VehicleUnitPrice = 'tes';
        atts.TradeInMake = 'tes';
        atts.TradeInModel = 'tes';
        atts.TradeInYearModel = 'tes';
        atts.TradeInVin = 'tes';
        atts.TradeInOdometer = 'tes';
        atts.TradeInPrice = 'tes';
        atts.TradeInStockNumber = 'tes';
        atts.HasMatchedCorporatePartnerAccount = false;
        atts.MatchedCorporatePartnerAccountId = 'tes';
        atts.MatchedCorporatePartnerAccountName = 'tes';
        atts.ContactEmail = 'tes';
        atts.ContactPhoneMobile = 'tes';
        atts.PrimaryContactName = 'tes';
        atts.PrimaryContactId = 'tes';
        atts.IsPersonAccount = false;
    }
}