@isTest
public class TestClass_LeadCreator {
    
    public static Lead CreateLeadWithNoPurchaseType()
    {
        Lead lead = BuildLead();
        lead.Purchase_Type__c = '';
        return lead;
    }
    
    public static Lead CreateLead()
    {
        Lead lead = BuildLead();
        
        insert lead;
        return lead;
    }
    
    public static Lead CreateConvertableLead(String accountType)
    {
        Lead lead = BuildLead();
        
        lead.Account_Type__c = accountType;
        lead.Budget__c = 1;
        lead.Industry = 'Other';
        lead.In_Market_Date__c = Date.today();
        
        insert lead;
        return lead;
    }
    
    private static Lead BuildLead()
    {
        Lead lead = new Lead();
        
        lead.LastName = 'lastname';
        lead.RecordTypeId = [Select Id From RecordType Where SObjectType='Lead' And DeveloperName='Generic' Limit 1].Id;
        lead.Purchase_Type__c = 'New Vehicle';
        lead.MobilePhone = '1234567890';
        
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        lead.Brand__c = make.Id;
        lead.Industry = 'Other';
        lead.In_Market_Date__c = Date.today();
        lead.Primary_Model_Interest__c = TestClass_VehicleSpecificationBuilder.BuildModel(make).id;
        
        return lead;
    }
}