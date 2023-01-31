public class DMSInboundRequestValidator_Factory {
    public DMSInboundRequestValidator Create(List<Id> requestedIds)
    {
    	List<I_DMSInboundRequestValidationRule> validationRules = new List<I_DMSInboundRequestValidationRule>();
    	
    	DMSInboundRequestStageValidationRule_Fac stageValidationRuleFactory = new DMSInboundRequestStageValidationRule_Fac();    	
    	DMSInboundRequestStageValidationRule stageValidationRule = stageValidationRuleFactory.Create();
    	
    	DMSInboundRequestOpportunityExistsRule_F opportunityExistsRuleFactory = new DMSInboundRequestOpportunityExistsRule_F();
    	DMSInboundRequestOpportunityExistsRule opportunityExistsRule = opportunityExistsRuleFactory.Create(requestedIds);
    	
    	I_DateAdapter dateAdapter = new Date_India();
    	I_TimeAdapter timeAdapter = new TimeAdapter_HHMMSS();
    	DateTimeAdapter dateTimeAdapter = new DateTimeAdapter(dateAdapter, timeAdapter);
    	DMSInboundRequestFormatValidationRule formatValidationRule = new DMSInboundRequestFormatValidationRule(dateTimeAdapter);
        DMSInboundDuplicateRequestRule duplicateRule = new DMSInboundDuplicateRequestRule(new Map<Id, DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity>(), dateTimeAdapter);
    	
    	validationRules.add(new DMSInboundRequestMandatoryFieldsRule());
    	validationRules.add(stageValidationRule);
    	validationRules.add(opportunityExistsRule);
    	validationRules.add(formatValidationRule);
        validationRules.add(duplicateRule);
    	
    	return new DMSInboundRequestValidator(validationRules);
    }
}