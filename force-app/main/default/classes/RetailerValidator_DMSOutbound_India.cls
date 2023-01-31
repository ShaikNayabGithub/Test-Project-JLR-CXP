public class RetailerValidator_DMSOutbound_India implements I_OpportunityValidator{
    public void Validate(Opportunity opportunity)
    {
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account, Schema.sObjectType.Account.fields.Preferred_Sales_Retailer__c);
        DMS_FieldPopulatedValidator.CheckField(opportunity.Account.Preferred_Sales_Retailer__r, Schema.sObjectType.Account.fields.Dealer_CI_Code__c);
    }
}