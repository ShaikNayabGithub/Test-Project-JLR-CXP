@isTest
public class OpportunityPrimaryAccountUpdaterTest {
    static testmethod void PrimaryAccountUpdateTest(){
  User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.RunAs(thisUser)
        {
            Account retailerAccount = new Account();
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = [select Id from RecordType where Name = 'Retailer' and SobjectType = 'Account' limit 1].Id;
            insert retailerAccount;
            Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
            User portaluser = createuser(retailerAccount,salesExecutiveProfile.Id);
            
            Data_Enrichment_Priority_on_Opportunity__c priority = new Data_Enrichment_Priority_on_Opportunity__c();
            priority.Data_Enrichment_Priority_Effective_To__c = 11;
            priority.Data_Enrichment_Priority_Level__c = 1;
            priority.Field_API_Name__c = 'StageName';
            priority.Field_Value__c = 'Negotiation';            
            priority.SetupOwnerId = UserInfo.getOrganizationId();
            insert priority;
            
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
                Opportunity newOpp = new Opportunity(AccountId = account.Id, OwnerId = userInfo.getUserId(), Name = 'newName', CloseDate = Date.today(), StageName = 'Contacted');
                insert newOpp;
                //Opportunity newOpp = TestClass_ValidOpportunityBuilder.opportunityWithopportunityitem();
                test.startTest();
                newOpp.StageName = 'Negotiation';
                update newOpp;
               
                test.stopTest();
               
            }
             Opportunity testOpportunity = [SELECT Id,OwnerId FROM Opportunity LIMIT 1];
            testOpportunity.OwnerId = thisUser.Id ;
            update testOpportunity;
            List<Account> primaryAccount = [SELECT Id,Data_Enrichment_Priority_Level__c, Data_Enrichment_Priority_Effective_To__c FROM Account WHERE Is_Primary__c=true];
                    //system.assert(primaryAccount.Data_Enrichment_Priority_Level__c>=1); //DJB CHANGE BACK
        }
        
    }
    
    private static User createuser(Account testCommAccount,Id profileId)
    {
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = testCommAccount.Id;
        testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = profileId;
        commUser.UserName = 'test@test.test.retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8'; 
        insert commUser;
        return commUser;
    }
}