@isTest
public class DMSOutbound_OwnerDMSIdValidationRule_Te {
    static testmethod void Validate_DoesNotThrowException_GivenValidOpportunity()
    {
        DMSOutbound_OwnerDMSIdValidationRule validator = new DMSOutbound_OwnerDMSIdValidationRule();

        Opportunity opportunity = CreateValidOpportunity();
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }

    static testmethod void Validate_ThrowsException_GivenNullOpportunityDMSIds()
    {
        DMSOutbound_OwnerDMSIdValidationRule validator = new DMSOutbound_OwnerDMSIdValidationRule();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.DMS_Opportunity_ID__c = null;
        opportunity.Owner.DMS_Id__c = null;

        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }

    static testmethod void Validate_ThrowsException_GivenNullAccountDMSIds()
    {
        DMSOutbound_OwnerDMSIdValidationRule validator = new DMSOutbound_OwnerDMSIdValidationRule();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Account.owner.DMS_Id__c = null;
        opportunity.Account.DMS_Identifier__c = null;

        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }

    static testmethod void Validate_ThrowsException_GivenNullContactDMSIds()
    {
        DMSOutbound_OwnerDMSIdValidationRule validator = new DMSOutbound_OwnerDMSIdValidationRule();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.OpportunityContactRoles[0].Contact.Owner.DMS_Id__c = null;
        opportunity.OpportunityContactRoles[0].Contact.DMS_Identifier__c = null;

        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }

    private static Opportunity CreateValidOpportunity()
    {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        Contact contact = TestClass_ValidContactBuilder.Build(opportunity.Account);
        insert opportunity;

        OpportunityContactRole opportunityContactRole = new OpportunityContactRole();
        opportunityContactRole.ContactId = contact.Id;
        opportunityContactRole.OpportunityId = opportunity.Id;
        opportunityContactRole.IsPrimary=true;
        insert opportunityContactRole;

        opportunity = [Select AccountId, Owner.DMS_Id__c, LeadSource, Brand__c, Primary_Model_Interest__c, Derivative__c, DMS_Opportunity_ID__c, Description, Budget__c,
            Account.Name, Account.Phone, Account.Site__c, Account.ntt_Jaguar_Status__c, Account.ntt_Land_Rover_Status__c, Account.RecordTypeId, 
            Account.RecordType.DeveloperName, Account.Preferred_Sales_Retailer__c, Account.ownerid, Account.DMS_Identifier__c, Account.BillingCity, 
            Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, Account.owner.DMS_Id__c,
            Account.Preferred_Sales_Retailer__r.Name, Account.Preferred_Sales_Retailer__r.Primary_Dealer_Code__c, Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c,
            (Select Product2.Name, Model__r.Name, Brand__r.Name From OpportunityLineItems Limit 1),
            (Select Contact.LastName, Contact.Account.ownerid, Contact.FirstName, Contact.MobilePhone, Contact.Salutation, Contact.Gender__c, Contact.HomePhone, 
            Contact.OtherPhone, Contact.Fax, Contact.Email, Contact.Email2__c, Contact.DMS_Identifier__c, Contact.Language__c, Contact.DoNotCall, 
            Contact.HasOptedOutOfEmail, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, Contact.MailingState, 
            Contact.MailingStreet, Contact.Owner.DMS_Id__c From OpportunityContactRoles Where IsPrimary=true) 
            From Opportunity
              Where Id=:opportunity.Id];
        
        opportunity.Owner = new User();
        opportunity.Owner.DMS_Id__c = 'test owner dms id';
        opportunity.DMS_Opportunity_ID__c = 'test opp dms id';
        opportunity.Account.owner.DMS_Id__c = 'test account owner dms id';
        opportunity.Account.DMS_Identifier__c = 'test account dms id';
        opportunity.OpportunityContactRoles[0].Contact.Account = new Account();
        opportunity.OpportunityContactRoles[0].Contact.Account.owner= new User();
        opportunity.OpportunityContactRoles[0].Contact.Account.owner.DMS_Id__c = 'test contact owner dms id';
        opportunity.OpportunityContactRoles[0].Contact.DMS_Identifier__c = 'test contact dms id';

        return opportunity;
    }
}