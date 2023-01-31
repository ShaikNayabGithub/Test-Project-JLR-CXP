/**
 * Created by caleb@argologic.com.au on 26/05/2020.
 */

global with sharing class CreateOpportunityInboundAttributeDto
{
    //todo - many of the properties below are not being used.
    @AuraEnabled
    global String PurchaseType { get; set;}
    @AuraEnabled
    global String ItemType { get; set;}
    @AuraEnabled
    global String RequestType { get; set;}
    @AuraEnabled
    global String ItemEnquiryType {get; set;}
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
    global Decimal ItemDap {get; set;}
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
    global String TestDriveDate {get; set;}
    @AuraEnabled
    global String ServiceDate {get; set;}
    @AuraEnabled
    global Boolean RetailingDealer {get; set;}
    @AuraEnabled
    global Boolean IsVWFS {get; set;}
    @AuraEnabled
    global String VWFSLoadId {get; set;}
    @AuraEnabled
    global String CreateServiceActivity {get; set;}
    @AuraEnabled
    global String CreateAsOpportunity {get; set;}
    @AuraEnabled
    global String VIN {get; set;}
    @AuraEnabled
    global Boolean createActivity {get; set;}
}