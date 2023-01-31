public class OpportunityValidator_Factory_DMSOutbound {
    public I_OpportunityValidator CreateIndia()
    {
        List<I_OpportunityValidator> validationRules = new List<I_OpportunityValidator>();

        DMSOutbound_IsApprovedRule isApprovedRule = new DMSOutbound_IsApprovedRule();
        validationRules.add(isApprovedRule);

        DMSOutbound_PriceBookRule priceBookRule = new DMSOutbound_PriceBookRule();
        validationRules.add(priceBookRule);

        DMSOutboundOpportunityValidator_India opportunityValidator = new DMSOutboundOpportunityValidator_India();
        validationRules.add(opportunityValidator);
        
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        validationRules.add(accountValidator);

        RetailerValidator_DMSOutbound_India retailerValidator = new RetailerValidator_DMSOutbound_India();
        validationRules.add(retailerValidator);

        ContactRoleValidator_DMSOutbound_India contactRoleValidator = new ContactRoleValidator_DMSOutbound_India();
        validationRules.add(contactRoleValidator);

        HasChangedSinceLastSentValidationRule recentlySentRule = new HasChangedSinceLastSentValidationRule();
        validationRules.add(recentlySentRule);

        DMSOutbound_PhoneFormatRule phoneFormatRule = new DMSOutbound_PhoneFormatRule();
        validationRules.add(phoneFormatRule);

        DMSOutbound_OwnerDMSIdValidationRule ownerValidator = new DMSOutbound_OwnerDMSIdValidationRule();
        validationRules.add(ownerValidator);

        DMSOutbound_OpportunityStageValidator_Fa stageValidatorFactory = new DMSOutbound_OpportunityStageValidator_Fa();
        DMSOutbound_OpportunityStageValidator stageValidator = stageValidatorFactory.Create();
        validationRules.add(stageValidator);

        return new OpportunityValidator(validationRules);
    }
}