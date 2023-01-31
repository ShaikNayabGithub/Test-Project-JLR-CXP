@isTest(SeeAllData=true)
public class AccountValidator_DMSOutbound_India_Test {
    static testMethod void Validate_DoesNotThrowException_GivenFullyPopulatedValidAccount() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, false);
    }
    
    static testMethod void Validate_DoesNotThrowException_GivenAccountMissingJaguarStatus() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.ntt_Jaguar_Status__c = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, false);
    }
    
    static testMethod void Validate_DoesNotThrowException_GivenAccountMissingLandRoverStatus() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.ntt_Land_Rover_Status__c = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, false);
    }

    static testMethod void Validate_ThrowsException_GivenNullAccount() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, true);
    }
    
    static testMethod void Validate_ThrowsException_GivenAccountMissingLandRoverAndJaguarStatus() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.ntt_Land_Rover_Status__c = null;
        opportunity.Account.ntt_Jaguar_Status__c = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, true);
    }
    
    static testMethod void Validate_ThrowsException_GivenAccountMissingName() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.Name = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, true);
    }
    
    static testMethod void Validate_ThrowsException_GivenAccountMissingPhone() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.Phone = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, true);
    }
    
    static testMethod void Validate_ThrowsException_GivenAccountMissingSite() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.Site__c = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, true);
    }
    
    static testMethod void Validate_ThrowsException_GivenAccountMissingRecordType() {
        AccountValidator_DMSOutbound_India accountValidator = new AccountValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.RecordTypeId = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(accountValidator, opportunity, true);
    }    
    
    private static Opportunity CreateValidOpportunity()
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Account = new Account();
        opportunity.Account.RecordType = new RecordType();
        
        opportunity.Account.Name = 'Valid';
        opportunity.Account.Phone = 'Valid';
        opportunity.Account.Site__c = 'Valid';
        opportunity.Account.ntt_Jaguar_Status__c = 'Valid';
        opportunity.Account.ntt_Land_Rover_Status__c = 'Valid';
        opportunity.Account.RecordType.DeveloperName = 'Corporate';
        opportunity.Account.RecordTypeId = [Select Id From RecordType Where SObjectType='Account' and DeveloperName='Corporate' Limit 1].Id;
        
        return opportunity;
    }
}