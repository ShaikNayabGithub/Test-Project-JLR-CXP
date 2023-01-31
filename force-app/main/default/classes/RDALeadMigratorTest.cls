/*
*  @Name : RDALeadMigratorTest 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-644
*  @Description : test class for RDALeadMigratorBatch

*/

@isTest
public class RDALeadMigratorTest {    
    static testmethod void RDALeadMigratorBatchTest() {
        
        User portaluser = TestUtility.createPortaluser('India','Sales Executive');
        System.RunAs(portaluser){
            Account account = new Account();        
            account.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
            account.LastName = 'test';
            account.FirstName = 'Valid Firstname';
            account.PersonMailingStreet = 'Valid Street';
            account.PersonMailingPostalCode = 'Valid PostalCode';
            account.PersonMailingState = 'Valid State';
            account.PersonMailingCity = 'Valid City';        
            account.PersonEmail = 'test@test.com';      
            account.Country_ISO_Code__c = 'IN';                
            account.Phone = '1234567890';
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(account, dml);
            system.debug('primaryAccount'+account);
            Lead newLead = TestClass_LeadCreator.CreateLeadWithNoPurchaseType();
            newLead.Purchase_Type__c = 'New Vehicle';
            insert newLead;
            User loggedinuser = [Select Id,AccountId from User Where Id=:userinfo.getUserId()];
            RDALeadMigratorBatch batchclass = new RDALeadMigratorBatch(loggedinuser.AccountId);
        	Database.executeBatch(batchclass, 100);
        }
    }
    
}