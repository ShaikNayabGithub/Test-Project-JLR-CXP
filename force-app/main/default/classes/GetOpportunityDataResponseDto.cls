/**
 * Created by caleb@argologic.com.au on 21/12/2020.
 */

public with sharing class GetOpportunityDataResponseDto
{
    // opportunity Info
    @AuraEnabled
    public string OpportunityId;
    @AuraEnabled
    public string OpportunityName;
    @AuraEnabled
    public string OpportunityStage;
    @AuraEnabled
    public Date OpportunityClosedDate;
    @AuraEnabled
    public string OpportunityInitialSaleType;
    @AuraEnabled
    public string OpportunityLeadSource;
    @AuraEnabled
    public string OpportunityEnquiryType;
    @AuraEnabled
    public string OpportunitySaleType;
    @AuraEnabled
     public string OpportunitySubType;
    @AuraEnabled
    public Boolean OpportunityIsClosed;

    // this is a linear stage
    // it will have 0, 1, 2 or 3 of these
    @AuraEnabled
    public string MakeId;
    @AuraEnabled
    public string MakeName;
    @AuraEnabled
    public string ModelId;
    @AuraEnabled
    public string ModelName;
    @AuraEnabled
    public string DerivativeName;
    @AuraEnabled
    public string DerivativeId;
    @AuraEnabled
    public string DerivativeModelYear;
    @AuraEnabled
    public string DerivativeEngine;

    @AuraEnabled
    public Boolean HasAsset;
    @AuraEnabled
    public string AssetName;
    @AuraEnabled
    public string AssetId;
    @AuraEnabled
    public boolean Isexdemo;
    
    // account and contact
    @AuraEnabled
    public boolean IsPersonAccount;
    @AuraEnabled
    public string AccountName;
    @AuraEnabled
    public string AccountId;
    @AuraEnabled
    public string ContactName; // will be null if person account
    @AuraEnabled
    public string ContactId;
    @AuraEnabled
    public string Email;
    @AuraEnabled
    public string Mobile;

    @AuraEnabled
    public Boolean HasCorporatePartner;
    @AuraEnabled
    public string CorporatePartnerName;
    @AuraEnabled
    public string CorporatePartnerId;

    @AuraEnabled
    public Boolean HasServicePlan;
    @AuraEnabled
    public string ServicePlanType;
    @AuraEnabled
    public string ServicePlanName;
    @AuraEnabled
    public string ServicePlanId;

    @AuraEnabled
    public string Pricebook2Id;

    @AuraEnabled
    public Boolean OpportunityHasBeenRdad;
    @AuraEnabled
    public string RdaName;
    @AuraEnabled
    public string RdaId;

    @AuraEnabled
    public Boolean CorporateEligibilityEnabled;
    @AuraEnabled
    public String CorporateEligibilityMessage;
}