/**
 * Created by Nick on 1/11/2019.
 */

public with sharing class SalesMatchController {

    public static GetSalesMatchResponseDto getAssets(GetSalesMatchRequestDto request) {

        List<RDA__c> rda_s = [
                SELECT Id,
                        Name,
                        Make__c,
                        CreatedDate,
                        Warranty_Start_Date__c,
                        Asset__r.Dealer_Code__c,
                        Asset__r.Model_Description__c,
                        Asset__r.Name_Plate__c,
                        Asset__r.Brand__r.Name,
                        Account__r.PersonTitle,
                        Contact__c,
                        Contact__r.Title,
                        Account__r.FirstName,
                        Contact__r.FirstName,
                        Account__r.LastName,
                        Contact__r.LastName,
                        Account__r.BillingStreet,
                        Contact__r.MailingStreet,
                        AU_Locality__r.Name,
                        Account__r.BillingState,
                        Contact__r.MailingState,
                        Account__r.BillingPostalCode,
                        Contact__r.MailingPostalCode,
                        Account__r.PersonOtherPhone,
                        Contact__r.OtherPhone,
                        Account__r.PersonHomePhone,
                        Contact__r.HomePhone,
                        Account__r.Retailer__c,
                        Account__r.Brand__c,
                        Account__r.Dealer_CI_Code__c,
                        Account__r.Dealer_CI_Code_2__c,
                        Account__r.PersonEmail,
                        Contact__r.Email,
                        Account__r.PersonMobilePhone,
                        Contact__r.MobilePhone,
                        Product_Name__c,
                        Model__c,
                        Account__r.Retailer_Name__c,
                        RecordType.Name,
                        Opportunity__r.Retailer_Name__c,
                        Opportunity__r.Retailer__r.Dealer_CI_Code_2__c,
                        Opportunity__r.Retailer__r.Dealer_CI_Code__c
                FROM RDA__c
                Where CreatedDate >= :request.CreatedDate
                AND Country__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
        ];

        List<Opportunity> opportunies = [
                SELECT Id,
                        CreatedDate,
                        Enquiry_Type__c,
                        LeadSource,
                        Campaign.Name,
                        Primary_Contact__r.FirstName,
                        Primary_Contact__r.LastName,
                        Primary_Contact__r.MailingStreet,
                        Primary_Contact__r.MailingCity,
                        Primary_Contact__r.MailingState,
                        Primary_Contact__r.MailingPostalCode,
                        Primary_Contact__r.Email,
                        Primary_Contact__r.MobilePhone
                From Opportunity
                where CreatedDate >= :request.CreatedDate
                AND Country_ISO_Code__c IN :Constants.COUNTRY_ISO_CODES_AUSTRALIA
        ];

        return new GetSalesMatchResponseDto(rda_s, opportunies);
    }
}