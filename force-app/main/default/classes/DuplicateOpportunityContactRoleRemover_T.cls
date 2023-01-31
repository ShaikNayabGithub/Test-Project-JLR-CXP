@isTest
public class DuplicateOpportunityContactRoleRemover_T {
    //no other way to test
    static testmethod void LeadConversion_CreatesOpportunityWithSingleContactRole_GivenPrivateLead()
    {
        Lead convertableLead = TestClass_LeadCreator.CreateConvertableLead('Private');
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        
        Database.LeadConvert leadConvert = new Database.LeadConvert();
        leadConvert.setLeadId(convertableLead.id);
        leadConvert.setOpportunityName('opportunityName');
        leadConvert.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult leadConvertResult = Database.convertLead(leadConvert);
        
        Opportunity opportunity = [Select (Select Id From OpportunityContactRoles) From Opportunity Where Id =:leadConvertResult.getOpportunityId()];
        
        System.assertEquals(1, opportunity.OpportunityContactRoles.size());
    }
}