@isTest
public class ContactRoleValidator_DMSOutbound_India_T {
    static testMethod void Validate_ReturnsTrue_GivenFullyPopulatedValidContactRoles() {
        ContactRoleValidator_DMSOutbound_India validator = new ContactRoleValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidContactRoles();
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }
    
    static testMethod void Validate_ReturnsTrue_GivenContactRolesMissingLastName() {
        ContactRoleValidator_DMSOutbound_India validator = new ContactRoleValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidContactRoles();
        opportunity.OpportunityContactRoles[0].Contact.LastName = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testMethod void Validate_ReturnsTrue_GivenContactRolesMissingFirstName() {
        ContactRoleValidator_DMSOutbound_India validator = new ContactRoleValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidContactRoles();
        opportunity.OpportunityContactRoles[0].Contact.FirstName = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testMethod void Validate_ReturnsTrue_GivenContactRolesMissingMobile() {
        ContactRoleValidator_DMSOutbound_India validator = new ContactRoleValidator_DMSOutbound_India();
        
        Opportunity opportunity = CreateValidContactRoles();
        opportunity.OpportunityContactRoles[0].Contact.MobilePhone = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    
    private static Opportunity CreateValidContactRoles()
    {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        Contact contact = TestClass_ValidContactBuilder.Build(new Account(Id=opportunity.AccountId));
        
        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.IsPrimary = true;
        opportunityContactRole.Role = 'Primary Contact';
        insert opportunityContactRole;
        
        opportunity = [Select (Select Contact.FirstName, Contact.LastName, Contact.MobilePhone From OpportunityContactRoles) From Opportunity Where Id=:opportunity.Id];
        opportunity.OpportunityContactRoles[0].Contact.FirstName = 'test';
        return opportunity;
    }
}