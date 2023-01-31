/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/09/2019.
 */

global with sharing class OfferAttributesDto extends AttributesDto{

    @AuraEnabled
    global String ServicePlanType {get; set;}

    @AuraEnabled
    global String ServicePlanName{get; set;}

    @AuraEnabled
    global Integer QantasPoints {get; set;}

    @AuraEnabled
    global Decimal DiscountAmount {get; set;}

    @AuraEnabled
    global Decimal DiscountPercentage {get; set;}

    @AuraEnabled
    global Decimal MinimumPurchasePrice {get; set;}

    @AuraEnabled
    global String Product2Id {get; set;}

    @AuraEnabled
    global String DateStart {get; set;}

    @AuraEnabled
    global String DateEnd {get; set;}

    @AuraEnabled
    global String CorporatePartnerId {get; set;}

    @AuraEnabled
    global String CorporatePartnerName {get; set;}
}