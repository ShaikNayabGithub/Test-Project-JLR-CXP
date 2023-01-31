/**
 * Created by caleb@argologic.com.au on 24/10/2019.
 */
@IsTest
public with sharing class TestClass_RDACreater
{
    public static RDA__c CreateRDA(String opportunityId, String corporateAccountId, String accountId, String assetId)
    {
        RDA__c rda = new RDA__c();
        rda.Opportunity__c = opportunityId;
        rda.Corporate_Account__c = corporateAccountId;
        rda.Account__c = accountId;
        rda.Asset__c = assetId;
        rda.Handover_Date__c = Datetime.now().addDays(2).date();
        rda.Registration_Number__c = 'TestReg';
        rda.Common_Sale_Type__c = 'Test Type';
        rda.Retail_Offer__c = 'Loyalty Program';
        insert rda;
        return rda;
    }

    public static RDA__c BuildRDA(String opportunityId, String corporateAccountId, String accountId, String assetId)
    {
        RDA__c rda = new RDA__c();
        rda.Opportunity__c = opportunityId;
        rda.Corporate_Account__c = corporateAccountId;
        rda.Account__c = accountId;
        rda.Asset__c = assetId;
        rda.Handover_Date__c = Datetime.now().addDays(2).date();
        rda.Registration_Number__c = 'TestReg';
        rda.Common_Sale_Type__c = 'Test Type';
        rda.Retail_Offer__c = 'Loyalty Program';
        return rda;
    }

    public static RDA__c CreateRDA(String opportunityId, String corporateAccountId, String accountId, String assetId, String primaryContactId)
    {
        RDA__c rda = new RDA__c();
        rda.Opportunity__c = opportunityId;
        rda.Corporate_Account__c = corporateAccountId;
        rda.Account__c = accountId;
        rda.Asset__c = assetId;
        rda.Handover_Date__c = Datetime.now().addDays(2).date();
        rda.Registration_Number__c = 'TestReg';
        rda.Common_Sale_Type__c = 'Test Type';
        rda.Retail_Offer__c = 'Loyalty Program';
        rda.Contact__c = primaryContactId;
        insert rda;
        return rda;
    }
}