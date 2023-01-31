@isTest
public class LeadHandler_Test {
    
    static TestMethod void CheckLead_SetOwnerAsQueueIfBlank_CreatesLead(){
        List<Group> quesu = [SELECT Id, DeveloperName, Type, DoesSendEmailToMembers FROM Group Where Type = 'Queue'];
        system.debug('quesu '+quesu);
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(OwnerId =quesu[0].id, Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        List<Lead> leadsCreated = [SELECT Id,OwnerId, Preferred_Retailer__c FROM Lead WHERE Id = :webToLead.Id];
        system.debug('leadsCreated '+leadsCreated);
        System.assertEquals(quesu[0].id, leadsCreated[0].OwnerId);
        
    }
    
    //
    
    static TestMethod void CheckLead_SetMENAUpdatenk_CreatesLead(){
        List<Group> quesu = [SELECT Id, DeveloperName, Type, DoesSendEmailToMembers FROM Group Where Type = 'Queue'];
        system.debug('quesu '+quesu);
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Id rtstrem = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();
        Lead webToLead = new Lead(OwnerId =quesu[0].id, Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        
        webToLead.RecordTypeId = rtstrem;
        update webToLead;
        List<Lead> leadsCreated = [SELECT Id,OwnerId, Enquiry_Type__c FROM Lead WHERE Id = :webToLead.Id];
        system.debug('leadsCreated '+leadsCreated);
        System.assertEquals('KMI', leadsCreated[0].Enquiry_Type__c);
        delete webToLead;
    }
    
    static TestMethod void checkLead_SetCurrencyIsoHK_CreatesLead(){
        List<Group> quesu = [SELECT Id, DeveloperName, Type, DoesSendEmailToMembers FROM Group Where Type = 'Queue'];
        system.debug('quesu '+quesu);
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Id rtstrem = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();
        Lead webToLead = new Lead(OwnerId =quesu[0].id, Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        
        webToLead.Country_ISO_Code__c = 'HK';
        insert webToLead;
        List<Lead> leadsCreated = [SELECT Id,OwnerId,CurrencyIsoCode, Enquiry_Type__c FROM Lead WHERE Id = :webToLead.Id];
        system.debug('leadsCreated '+leadsCreated);
        System.assertEquals('HKD', leadsCreated[0].CurrencyIsoCode);
        delete webToLead;
    }
    
    static TestMethod void checkLead_SetCurrencyIsoNull_CreatesLead(){
        List<Group> quesu = [SELECT Id, DeveloperName, Type, DoesSendEmailToMembers FROM Group Where Type = 'Queue'];
        system.debug('quesu '+quesu);
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'KMI' AND sObjectType = 'Lead' LIMIT 1];
        Id rtstrem = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Streamlined_Lead_Process').getRecordTypeId();
        Lead webToLead = new Lead(OwnerId =quesu[0].id, Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        insert webToLead;
        List<Lead> leadsCreated = [SELECT Id,OwnerId,CurrencyIsoCode, Enquiry_Type__c FROM Lead WHERE Id = :webToLead.Id];
        system.debug('leadsCreated '+leadsCreated);
        System.assertEquals('HKD', leadsCreated[0].CurrencyIsoCode);
        delete webToLead;
    }
    
    static TestMethod void LeadConvertAccount(){
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailerAccount.DMS_Type__c = 'JobRouter';
        insert retailerAccount;
        RecordType rtkmi = [SELECT Id FROM RecordType WHERE Name = 'Streamlined Lead Process' AND sObjectType = 'Lead' LIMIT 1];
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', RecordTypeId = rtkmi.Id, LeadSource = System.Label.WebToLead_LeadSource, Mapping_Brand__c = 'Jaguar');
        webToLead.Preferred_Retailer__c = retailerAccount.id;
        webToLead.Country_ISO_Code__c = 'MA';
        webToLead.Enquiry_Type__c = 'Find & Price Enquiry';
        test.startTest();
        insert webToLead;
        test.stopTest();
    }
    
    static TestMethod void LeadConvertJPWebLead(){
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'System_Administrator' Limit 1];
        Group  groupIns = [SELECT Id, Type, Name, DeveloperName FROM Group where DeveloperName = 'JLR_Kyoto_50140_Kyoto_s50140_13858' and type = 'Queue'];
        Profile prof = [select id,name from profile where name = 'Sales Manager/Receptionist'];
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'sta123', Email='standarduser2123@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = userrole.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2123@testorg2123.com12');
        insert u;
        Account retailerAccount;
        Contact conIns;
        
        system.runAs(u){
            retailerAccount = new Account();
            retailerAccount.Is_Primary__c = true;
            retailerAccount.Name = 'Test Account';
            retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
            retailerAccount.DMS_Type__c = 'JobRouter';
            retailerAccount.Queue_ID__c = groupIns.id;
            insert retailerAccount;
            
            conIns = new Contact();
            conIns.LastName = 'testjpcontact';
            conIns.accountid = retailerAccount.id;  
            conIns.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Retailer Contact').getRecordTypeId();
            conIns.Default_Retailer_Record_Owner__c = true;
            conIns.Email = 'testjp@testdevjp33.dev11';
            insert conIns;
        }
        
        User userIns = new user();
        userIns.lastname = 'testjpcontactuser';
        userIns.Email = 'testjp@testdevjp33.dev11';
        userIns.username = 'testjp@testdevjp33.dev11';
        userins.ProfileId = prof.id;
        userins.ContactId = conIns.id;
        userins.Title = 'title';
        userins.Alias = 'devjp33';
        userins.TimeZoneSidKey = 'America/Los_Angeles';
        userins.LanguageLocaleKey = 'en_US';
        userins.LocaleSidKey = 'en_US';
        userins.EmailEncodingKey = 'UTF-8';
        
        insert userIns;
        
        Lead webToLead = new Lead(Web2Lead_Check_Code__c = '5%2k9UB13#57486ki&29@JK53', LastName = 'UNIT Test', Email = 'unique@12345.com', LeadSource = System.Label.WebToLead_LeadSource,
                                  ownerid = groupIns.id,Mapping_Brand__c = 'Jaguar',Country_ISO_Code__c = 'JP',Secondary_Lead_Source__c = 'Showroom Visit Form');
        test.startTest();
        system.runAs(u){
            try{
            insert webToLead;
            }catch(Exception ex){
                system.debug('---> '+ex);
            }
        }
        test.stopTest();   
        
    }
    @IsTest
    static void Test_SetCustomerJourneyToSelect_WhenOpportunityCreated() {
        Opportunity opp = new Opportunity();
        Test.startTest();
        opp = createOpportunity();
        List<Id> opportunityIds = new List<Id>();
        opportunityIds.add(opp.id);
		InvocableSetPrimaryContactOnOpportunity.SetPrimaryContact(opportunityIds);
        Test.stopTest();
    }
    
    @IsTest
    static void testCXPtoDMSLead() {
        Test.startTest();
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        retailerAccount.DMS_Type__c = 'CDK';
        insert retailerAccount;
        insert new Lead(lastname = 'test', Preferred_Retailer__c = retailerAccount.id, email = 'abc@def.com', Enquiry_Type__c = 'Find & Price Enquiry', Country_ISO_Code__c = '	BH');
        Database.executeBatch( new Batch_CXPtoDMSLeads());
        Test.stopTest();
    }
    
      public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Testrec Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'testrec@test.test';
        testAccount.Customer_Journey_Stage__c = 'Take Ownership';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }
     
}