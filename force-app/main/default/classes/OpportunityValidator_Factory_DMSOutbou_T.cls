@isTest
public with sharing class OpportunityValidator_Factory_DMSOutbou_T {
    static testMethod void CreateIndia_ReturnsOpportunityValidator_WhenCalled() {
        OpportunityValidator_Factory_DMSOutbound validatorFactory = new OpportunityValidator_Factory_DMSOutbound();
        
        I_OpportunityValidator result = validatorFactory.CreateIndia();
        
        System.assertNotEquals(null, result);
    }
}