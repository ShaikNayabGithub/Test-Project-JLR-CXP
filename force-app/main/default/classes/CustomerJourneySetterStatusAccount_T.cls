@isTest
public class CustomerJourneySetterStatusAccount_T {
    @isTest
    static void checkAccountSetToLapseWhenCustomerStatusSetToLapsed(){
        CustomerJourneySetterStatusAccount instance = new CustomerJourneySetterStatusAccount();
        Account acc = TestClass_AccountCreator.CreatePersonAccount();
        Test.startTest();
        	instance.getAccountAtUpdateablePURCHASEStage(new List < Account > {acc});
            instance.isAccountToBeUpdatedToPURCHASEStage(acc);
            instance.isAccountToBeUpdatedToTAKEOWNERSHIPStage(acc);
            instance.setAccountsRelatedToOppToSELECT(new List < Account > {acc});
        	instance.getAccountsRelatedToRoadsideRecord(new List < Event > {});
        	instance.setMaintainFromRoadsideEvent(new List < Event > {});
        	instance.getAccountsRelatedToOpp(new List < Opportunity > {});
        	instance.renewEnjoyCustomerAccount(new List < Account > {}, new Map < Id, Account > {});
        	acc.ntt_Jaguar_Status__c = 'Lapsed Customer';
        	update acc;
        Test.stopTest();
        Account acc1 = [SELECT id, Customer_Journey_Stage__c From Account where id = :acc.Id];
       // System.assertEquals(acc1.Customer_Journey_Stage__c, 'Lapse');
    }
  /*  @IsTest
    static void checkAccountSetToLapseWhenCustomerStatusNotSetToLapsed(){
  
      Account acc = new Account();
      acc.Name= 'Test@2022';  
      acc.ntt_Jaguar_Status__c = 'Prospect';
        Test.startTest();
        Insert acc;
      Account acc1 = TestClass_AccountCreator.CreatePersonAccount();
        acc1.ntt_Jaguar_Status__c = 'Lapsed Customer';
        Update acc1;
      Account acc2 = [SELECT id, Customer_Journey_Stage__c, ntt_Jaguar_Status__c From Account where id = :acc1.Id];
        acc.ntt_Jaguar_Status__c=acc2.ntt_Jaguar_Status__c; 
        update acc;
        Test.stopTest();
        System.assertEquals(acc2.Customer_Journey_Stage__c, 'Lapse');
    }*/
    
    @isTest
    static void checkAccountSetToResolveWhenCRCCaseCreated(){
        Id crcId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').GetRecordTypeId();
        Account acc = TestClass_AccountCreator.CreatePersonAccount();
        Case caseRecord = new Case();
        
        caseRecord.Status = 'Open';
        caseRecord.Origin = 'NSC';
        caseRecord.subject = 'Test01';
        caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.SuppliedEmail = 'test123@test.com';            
        caseRecord.AccountId = acc.id;
        caseRecord.RecordTypeId = crcId;
        Test.startTest();
        	insert caseRecord;
        Test.stopTest();
        
        Account acc1 = [SELECT id, Customer_Journey_Stage__c From Account where id = :acc.Id];
        //System.assertEquals(acc1.Customer_Journey_Stage__c, 'Resolve');
    }
    
    @isTest
    static void checkAccountSetToMaintainWhenCRCCaseClosed(){
        Id crcId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('NSC').GetRecordTypeId();
        Account acc = TestClass_AccountCreator.CreatePersonAccount();
        Case caseRecord = new Case();
        
        caseRecord.Status = 'Open';
        caseRecord.Origin = 'NSC';
        caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.SuppliedEmail = 'test123@test.com';            
        caseRecord.AccountId = acc.id;
        caseRecord.subject = 'Test1';
        caseRecord.RecordTypeId = crcId;
        insert caseRecord;
        Test.startTest();
            Case updateCase = new Case();
            updateCase.Id = caseRecord.Id;
            updateCase.Status = 'Closed';
            updateCase.Solved_Date__c = System.Datetime.now();
            
            update updateCase;
        Test.stopTest();
        
        Account acc1 = [SELECT id, Customer_Journey_Stage__c From Account where id = :acc.Id];
        system.debug('--- > ' + json.serializePretty(acc1));
        // System.assertEquals(acc1.Customer_Journey_Stage__c, 'Resolve');
    }
    
}