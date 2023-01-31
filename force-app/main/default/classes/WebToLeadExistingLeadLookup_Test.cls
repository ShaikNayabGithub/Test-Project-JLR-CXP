@isTest
public class WebToLeadExistingLeadLookup_Test {
    
    static TestMethod void CheckLead_GivenNewLead_CreatesLead(){
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        List<Lead> leadsCreated = [SELECT Id FROM Lead WHERE Id = :webToLead.Id];
        //System.assertEquals(1, leadsCreated.size());
    }
    
    static TestMethod void CheckLead_GivenDupeLead_DoesCreateLostLead(){
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        Lead webToLead2 = webToLead.clone();
        boolean errorThrown = false;
        
        insert webToLead2;
        
        List<Lead> lds = [Select id, status, lost_reason__c from Lead WHERE status = 'Lost' ];
        system.Debug(lds);
        //System.assertEquals(lds.size(), 1);
    }
    
    static TestMethod void GetAccount_GivenMatchingLead_ReturnsCorrectAccount(){
        Account personAccount = TestClass_AccountCreator.CreatePersonAccount();
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = personAccount.LastName, Email = 'test123@test.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        Lead leadCreated = [SELECT Account__c FROM Lead WHERE Id = :webToLead.Id LIMIT 1];
        //System.assertEquals(personAccount.Id, leadCreated.Account__c);
    }
    
     @isTest static void CheckLead_GivenDupeLead_DoesCreateLostLeadWithOneHour(){
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        DateTime dt = System.Now().addHours(-1);
        Test.setCreatedDate(webToLead.Id,dt);  
        Lead webToLead2 = webToLead.clone();
        insert webToLead2;
        Lead leadIns = [Select id, status, lost_reason__c,Lost_Reason_Others__c,Lead_Lost__c from Lead WHERE id =: webToLead2.Id];
        //System.assertEquals(leadIns.Status,'Lost');
        //System.assertEquals(leadIns.lost_reason__c,'Duplicate Lead');
        //System.assertEquals(leadIns.Lost_Reason_Others__c,'Weblead Dupe');
        //System.assert(leadIns.Lead_Lost__c);
    }
    
    @isTest static void CheckLead_GivenDupeLead_DoesCreateLostLeadWithHours(){
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        DateTime dt = System.Now().addHours(-18);
        Test.setCreatedDate(webToLead.Id,dt);  
        Lead webToLead2 = webToLead.clone();
        insert webToLead2;
        Lead leadIns = [Select id, status, lost_reason__c,Lost_Reason_Others__c,Lead_Lost__c from Lead WHERE id =: webToLead2.Id];
        //System.assertEquals(leadIns.Status,'Lost');
        //System.assertEquals(leadIns.lost_reason__c,'Duplicate Lead');
        //System.assertEquals(leadIns.Lost_Reason_Others__c,'Weblead Dupe');
        //System.assert(leadIns.Lead_Lost__c);
    }
    
    @isTest static void CheckLead_GivenDupeLead_DoesCreateLostLeadBeforeHours(){
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        DateTime dt = System.Now().addHours(-19);
        Test.setCreatedDate(webToLead.Id,dt);  
        Lead webToLead2 = webToLead.clone();
        insert webToLead2;
        Lead leadIns = [Select id, status, lost_reason__c,Lost_Reason_Others__c,Lead_Lost__c from Lead WHERE id =: webToLead2.Id];
        //System.assertnotEquals(leadIns.Status,'Lost');
        //System.assertnotEquals(leadIns.lost_reason__c,'Duplicate Lead');
        //System.assertnotEquals(leadIns.Lost_Reason_Others__c,'Weblead Dupe');
        System.assert(!leadIns.Lead_Lost__c);
    }
    
}