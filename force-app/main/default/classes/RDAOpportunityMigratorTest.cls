/*
*  @Name : RDAOpportunityMigratorTest 
*  @Author : Masthan Andela 
*  @JIRA Number: CXPDA-644
*  @Description : test class for RDAOpportunityMigratorBatch

*/

@isTest
public class RDAOpportunityMigratorTest {   
    public static Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Pre_Approval_Overseas').getRecordTypeId();
    
    static testmethod void RDAOpportunityMigratorBatchTest() {
        
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
            Opportunity newOpp = new Opportunity(AccountId = account.Id, OwnerId = userInfo.getUserId(), Name = 'newName', CloseDate = Date.today(), StageName = 'Contacted',
                                                 RecordtypeId = opportunityRecordTypeId);
            insert newOpp;
            User loggedinuser = [Select Id,AccountId from User Where Id=:userinfo.getUserId()];
            RDAOpportunityMigratorBatch batchclass = new RDAOpportunityMigratorBatch(loggedinuser.AccountId);
            Database.executeBatch(batchclass, 100);
        }
    }
    
}