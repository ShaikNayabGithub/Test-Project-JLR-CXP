/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 25/11/2019.
 */

global with sharing class ServicePlanAttributeDto extends AttributesDto{

    @AuraEnabled
    global Integer QantasPoints {get; set;}

    @AuraEnabled
    global Decimal MinimumPurchasePrice {get; set;}

    @AuraEnabled
    global Decimal DiscountAmount {get; set;}

    @AuraEnabled
    global Decimal DiscountPercentage {get; set;}

    @AuraEnabled
    global String ServicePlanType {get; set;}

    @AuraEnabled
    global String ServicePlanName {get; set;}

    @AuraEnabled
    global Decimal Kilometers {get; set;}

    @AuraEnabled
    global Decimal Months {get; set;}

    @AuraEnabled
    global String DateStart {get; set;}

    @AuraEnabled
    global String DateEnd {get; set;}

    @AuraEnabled
    global String CorporatePartnerId {get; set;}

    @AuraEnabled
    global String PricebookEntryId {get; set;}

    @AuraEnabled
    global String OpportunityId {get; set;}

    @AuraEnabled
    global String CorporatePartnerName {get; set;}

    @AuraEnabled
    global String UnitPrice {get; set;}
}