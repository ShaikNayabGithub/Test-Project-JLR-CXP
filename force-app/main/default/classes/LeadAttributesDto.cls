/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 6/09/2019.
 */

global with sharing class LeadAttributesDto extends AttributesDto{


    //todo - many of the properties below are not being used.
    @AuraEnabled
    global String SellerIdentifier { get; set;}
    @AuraEnabled
    global String Service { get; set;}
    @AuraEnabled
    global String LeadType { get; set;}
    @AuraEnabled
    global String ItemType { get; set;}
    @AuraEnabled
    global String RequestType { get; set;}
    @AuraEnabled
    global String Status { get; set;}
    @AuraEnabled
    global String EnvironmentSiteOrigin { get; set;}
    @AuraEnabled
    global String ItemEnquiryType {get; set;}
    @AuraEnabled
    global String EnvironmentPageSource { get; set;}
    @AuraEnabled
    global String EnvironmentIPAddress { get; set;}
    @AuraEnabled
    global String EnvironmentSessionId { get; set;}
    @AuraEnabled
    global String ProspectTitle { get; set;}
    @AuraEnabled
    global String ProspectNameFirst { get; set;}
    @AuraEnabled
    global String ProspectNameLast { get; set;}
    @AuraEnabled
    global String ProspectCompanyName { get; set;}
    @AuraEnabled
    global String ProspectAddressLine1 { get; set;}
    @AuraEnabled
    global String ProspectAddressLine2 { get; set;}
    @AuraEnabled
    global String ProspectAddressSuburb { get; set;}
    @AuraEnabled
    global String ProspectAddressState { get; set;}
    @AuraEnabled
    global String ProspectAddressPostcode { get; set;}
    @AuraEnabled
    global String ProspectEmail { get; set;}
    @AuraEnabled
    global String ProspectPhoneHome { get; set;}
    @AuraEnabled
    global String ProspectPhoneMobile { get; set;}
    @AuraEnabled
    global String ProspectPhoneWork { get; set;}
    @AuraEnabled
    global String ProspectPreferredTestDriveDate {get; set;}
    @AuraEnabled
    global String ItemStockNumber { get; set;}
    @AuraEnabled
    global String ItemMake { get; set;}
    @AuraEnabled
    global String ItemModel { get; set;}
    @AuraEnabled
    global String ItemSeries { get; set;}
    @AuraEnabled
    global Integer ItemYear { get; set;}
    @AuraEnabled
    global Decimal ItemPrice { get; set;}
    @AuraEnabled
    global String ItemRegistrationNumber { get; set;}
    @AuraEnabled
    global String ItemEngineDescription { get; set;}
    @AuraEnabled
    global String ItemTransmission { get; set;}
    @AuraEnabled
    global String ItemColour { get; set;}
    @AuraEnabled
    global String ItemBodyType { get; set;}
    @AuraEnabled
    global String ItemFuelType { get; set;}
    @AuraEnabled
    global Decimal ItemOdometer{ get; set;}
    @AuraEnabled
    global String ItemDetailsUrl { get; set;}
    @AuraEnabled
    global String ItemVehicleIdentificationNumber {get; set;}
    @AuraEnabled
    global List<String> Tags  { get; set;}
    @AuraEnabled
    global String DealerCode {get; set;}
    @AuraEnabled
    global String Comments { get; set;}
    @AuraEnabled
    global String TradeInMake {get; set;}
    @AuraEnabled
    global String TradeInModel {get; set;}
    @AuraEnabled
    global Integer TradeInYear {get; set;}
    @AuraEnabled
    global Decimal TradeInOdometer {get; set;}
    @AuraEnabled
    global String TradeInColor {get; set;}
    @AuraEnabled
    global String ExternalId {get; set;}
    @AuraEnabled
    global String DepositTransactionId {get; set;}
    @AuraEnabled
    global String DepositStatus {get; set;}
    @AuraEnabled
    global Decimal DepositReservationAmount {get; set;}
}