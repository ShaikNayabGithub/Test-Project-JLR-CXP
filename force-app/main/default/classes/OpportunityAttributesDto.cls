/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 27/08/2019.
 */

global with sharing class OpportunityAttributesDto extends AttributesDto
{
    global OpportunityAttributesDto(){
        super();
        init();
    }

    private void init(){
        this.HasMatchedCorporatePartnerAccount = false;
        this.IsMarketingPermitted = false;
    }

    //Account
    @AuraEnabled
    global String AccountId {get; set;}
    @AuraEnabled
    global String AccountName {get; set;}

    //@AuraEnabled
    //global String Priority {get; set;}
    @AuraEnabled
    public String Stage {get; set;}
    @AuraEnabled
    global String Pricebook2Id {get; set;}
    public String SystemName {get; set;}
    public String RequestDateTime {get; set;}
    @AuraEnabled
    public String EnquiryType {get; set;}
    @AuraEnabled
    public String SaleType {get; set;}
    public Boolean IsMarketingPermitted {get; set;}
    @AuraEnabled
    public String LeadSource {get; set;}
    public String LeadType {get; set;}
    public String DealerCode {get; set;}
    public String CampaignName {get; set;}
    public Boolean DoDistributeToDealer {get; set;}
    public String Comments {get; set;}
    public String Notes {get; set;}
    public String Status {get; set;}
    public String ContactType {get; set;}
    public String OpportunityId {get; set;}
    public String BuyerAccountId {get; set;}
    public String BuyerNameTitle {get; set;}
    public String BuyerNameFirst {get; set;}
    @AuraEnabled
    public String BuyerNameLast {get; set;}
    public String BuyerAgeGroup {get; set;}
    public String BuyerCompanyName {get; set;}
    public String BuyerAddressLine1 {get; set;}
    public String BuyerAddressLine2 {get; set;}
    public String BuyerAddressLine3 {get; set;}
    public String BuyerAddressLine4 {get; set;}
    public String BuyerAddressCity {get; set;}
    public String BuyerAddressState {get; set;}
    public String BuyerAddressPostcode {get; set;}
    public String BuyerPhoneMobile {get; set;}
    public String BuyerPhoneWork {get; set;}
    public String BuyerPhoneHome {get; set;}
    public String BuyerEmailPersonal {get; set;}
    public String BuyerEmailBusiness {get; set;}
    @AuraEnabled
    public String VehicleBrand {get; set;}
    @AuraEnabled
    public String VehicleModel {get; set;}
    public String VehicleBodyStyle {get; set;}
    public String VehicleModelYear {get; set;}
    public String VehicleEngineType {get; set;}
    public String VehicleTrim {get; set;}
    public String VehicleDescription {get; set;}
    //Values should be New, Used or Unknown
    public String VehicleCondition {get; set;}
    public String VehicleAlternateModels {get; set;}
    public String VehicleUnitPrice {get; set;}
    public String TradeInMake {get; set;}
    public String TradeInModel {get; set;}
    public String TradeInYearModel {get; set;}
    public String TradeInVin {get; set;}
    //Kilometers
    public String TradeInOdometer {get; set;}
    public String TradeInPrice {get; set;}
    public String TradeInStockNumber {get; set;}

    @AuraEnabled
    public Boolean HasMatchedCorporatePartnerAccount {get; set;}

    @AuraEnabled
    public String MatchedCorporatePartnerAccountId {get; set;}

    @AuraEnabled
    public String MatchedCorporatePartnerAccountName {get; set;}

    @AuraEnabled
    public String ContactEmail {get; set;}

    @AuraEnabled
    public String ContactPhoneMobile {get; set;}

    @AuraEnabled
    public String PrimaryContactName {get; set;}

    @AuraEnabled
    public String PrimaryContactId {get; set;}

    @AuraEnabled
    public Boolean IsPersonAccount {get; set;}
}