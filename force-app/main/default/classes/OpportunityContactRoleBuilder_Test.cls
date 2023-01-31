@isTest
public class OpportunityContactRoleBuilder_Test {
    static testMethod void CorporateAccountContactRole() {
        Lead objLead = new Lead(FirstName = 'Testdev1', email = 'jlrTestdev@testdev.dev123',LastName = 'jlrDev1', Company = 'Testing jlrDev1');  
        insert objLead;  
        
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId(objLead.Id);  
        lc.setDoNotCreateOpportunity(false);  
        lc.setConvertedStatus('Qualified'); 
        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);  
        system.debug( 'Errors are ' + lcr.getErrors() );  
        system.assert( lcr.isSuccess() );  
        Test.stopTest();
        Lead ldIns = [select  id,ConvertedOpportunityId from Lead where id =: objLead.Id];
        List<OpportunityContactRole> contactRoleList = [select id,Role,isprimary from OpportunityContactRole where Opportunityid =:ldIns.ConvertedOpportunityId];
        system.assertequals(contactRoleList.size(),1); 
        if(contactRoleList != null && !contactRoleList.isEmpty()){
            OpportunityContactRole contactRole = contactRoleList.get(0);
            system.assertequals(contactRole.Role,'Primary Contact'); 
            system.assertequals(contactRole.isprimary,true); 
        }
        OpportunityContactRoleCreator_Factory factoryIns = new OpportunityContactRoleCreator_Factory();
        OpportunityContactRoleBuilder builderIns = new OpportunityContactRoleBuilder();
    }
    static testMethod void personAccountContactRole() {
        Lead objLead = new Lead(FirstName = 'Testdev1', email = 'jlrTestdev@testdev.dev123',LastName = 'jlrDev1');  
        insert objLead;  
        
        Database.LeadConvert lc = new database.LeadConvert();  
        lc.setLeadId(objLead.Id);  
        lc.setDoNotCreateOpportunity(false);  
        lc.setConvertedStatus('Qualified'); 
        Test.startTest();
        Database.LeadConvertResult lcr = Database.convertLead(lc, false);  
        system.debug( 'Errors are ' + lcr.getErrors() );  
        system.assert( lcr.isSuccess() );   
        Test.stopTest();
        Lead ldIns = [select  id,ConvertedOpportunityId from Lead where id =: objLead.Id];
        List<OpportunityContactRole> contactRoleList = [select id,Role,isprimary from OpportunityContactRole where Opportunityid =:ldIns.ConvertedOpportunityId];
        system.assertequals(contactRoleList.size(),1); 
        if(contactRoleList != null && !contactRoleList.isEmpty()){
            OpportunityContactRole contactRole = contactRoleList.get(0);
            system.assertequals(contactRole.Role,'Primary Contact'); 
            system.assertequals(contactRole.isprimary,true); 
        }
        
    }
}