@isTest
public class coop_CampaignSharingLogic_Test {
    
    static testmethod void CampaignTrigger_SharesRetailerCampaignWithRetailer_WhenRetailerPopulated() {
        
        UserRole ur = [Select id, name from UserRole where Name Like '%Partner Manager%' limit 1 ];        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();       
        testRetailer.Name = ur.Name.removeEnd(' Partner Manager');
        insert testRetailer;
        
        Test.startTest();
        Campaign retailerCampaign = new Campaign(Name='Test Campaign 1', RecordTypeId=retailerRecordTypeId, Retailer__c=testRetailer.Id);
        insert retailerCampaign;
        Test.stopTest();
        
        List<CampaignShare> cs = [SELECT Id, UserOrGroupId FROM CampaignShare WHERE CampaignId = :retailerCampaign.Id AND RowCause = 'Manual'];
        System.assertEquals(1, cs.size());
        
    }
    static testmethod void CampaignTrigger_SharesRetailerCampaignWithRetailers_WhenRetailerGroupPopulated() {       
       
        
        List<UserRole> urs = [Select id, name from UserRole where Name Like '%Partner Manager%' limit 2 ];
        System.debug('Urs '+JSON.serializePretty(urs));
        
        
        List<Account> accs = new List<Account>();
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        
        Account parentRetailer = TestClass_AccountCreator.BuildRetailer();
        parentRetailer.Record_Sub_Type__c = 'Dual Brand';
        parentRetailer.Name ='DEALER GROUP';
        parentRetailer.record_sub_type__c ='Legal Entity (Dealer Group)';
        insert parentRetailer;
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();    
        testRetailer.Name = urs[1].name.removeEnd(' Partner Manager');
        testRetailer.ParentId = parentRetailer.Id;
        
        Account testRetailer2 = TestClass_AccountCreator.BuildRetailer();    
        testRetailer2.Name = urs[0].name.removeEnd(' Partner Manager');
        testRetailer2.ParentId = parentRetailer.Id;
        accs.add(testRetailer2);
        accs.add(testRetailer);
        insert accs;
        
        Test.startTest();
        Campaign retailerCampaign = new Campaign(Name='Test Campaign 1', RecordTypeId=retailerRecordTypeId, Retailer__c=parentRetailer.Id);
        insert retailerCampaign;
        Test.stopTest();
        
        List<CampaignShare> cs = [SELECT Id, UserOrGroupId FROM CampaignShare WHERE CampaignId = :retailerCampaign.Id AND RowCause = 'Manual'];
        System.assertEquals(2, cs.size());
        
    }
    static testmethod void CampaignTrigger_SharesRetailerCampaignWithRetailers_WhenRetailerGroupPopulatedonUpdate() {    
        
        List<UserRole> urs = [Select id, name from UserRole where Name Like '%Partner Manager%' limit 2 ];
        List<Account> accs = new List<Account>();
        
        
        
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        
        Account parentRetailer = TestClass_AccountCreator.BuildRetailer();
        parentRetailer.Record_Sub_Type__c = 'Dual Brand';
        parentRetailer.Name ='DEALER GROUP';
        parentRetailer.record_sub_type__c ='Legal Entity (Dealer Group)';
        insert parentRetailer;
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();    
        testRetailer.Name = urs[1].name.removeEnd(' Partner Manager');
        testRetailer.ParentId = parentRetailer.Id;
        
        Account testRetailer2 = TestClass_AccountCreator.BuildRetailer();    
        testRetailer2.Name = urs[0].name.removeEnd(' Partner Manager');
        testRetailer2.ParentId = parentRetailer.Id;
        accs.add(testRetailer2);
        accs.add(testRetailer);
        insert accs;
        Campaign retailerCampaign = new Campaign(Name='Test Campaign 1', RecordTypeId=retailerRecordTypeId, Retailer__c=testRetailer2.Id);
        insert retailerCampaign;
        Test.startTest();
        
        retailerCampaign.Retailer__c = parentRetailer.id;
        update retailerCampaign;
        Test.stopTest();
        
        List<CampaignShare> cs = [SELECT Id, UserOrGroupId FROM CampaignShare WHERE CampaignId = :retailerCampaign.Id AND RowCause = 'Manual'];
        System.assertEquals(2, cs.size());
        
    }
    static testmethod void CampaignTrigger_SharescoopCampaignWithRetailers_WhenRetailerGroupPopulatedonCreation() {
        
      
        List<UserRole> urs = [Select id, name from UserRole where Name Like '%Partner Manager%' limit 2 ];  
        
        
        List<Account> accs = new List<Account>();
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        
        Account parentRetailer = TestClass_AccountCreator.BuildRetailer();
        parentRetailer.Record_Sub_Type__c = 'Dual Brand';
        parentRetailer.Name ='DEALER GROUP';
        parentRetailer.record_sub_type__c ='Legal Entity (Dealer Group)';
        insert parentRetailer;
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();    
        testRetailer.Name = urs[1].name.removeEnd(' Partner Manager');
        testRetailer.ParentId = parentRetailer.Id;
        
        Account testRetailer2 = TestClass_AccountCreator.BuildRetailer();    
        testRetailer2.Name = urs[0].name.removeEnd(' Partner Manager');
        testRetailer2.ParentId = parentRetailer.Id;
        accs.add(testRetailer2);
        accs.add(testRetailer);
        insert accs;
        Campaign retailerCampaign = new Campaign(Name='Test Campaign 1', RecordTypeId=retailerRecordTypeId, Retailer__c=parentRetailer.Id);
        insert retailerCampaign;
        Test.startTest();
        Campaign coopCampaign = new Campaign(Name='Test child Campaign 1', RecordTypeId=coopRecordTypeId, ParentId=retailerCampaign.Id);
        insert coopCampaign;
        Test.stopTest();
        
        List<CampaignShare> cs = [SELECT Id, UserOrGroupId FROM CampaignShare WHERE CampaignId = :coopCampaign.Id AND RowCause = 'Manual'];
        System.assertEquals(2, cs.size());
        
    }
    
    static testmethod void CampaignTrigger_SharescoopCampaignWithRetailers_WhenRetailerGroupPopulatedonUpdateOfParent() {
        
      
        List<UserRole> urs = [Select id, name from UserRole where Name Like '%Partner Manager%' limit 2 ];
        System.debug('Urs '+JSON.serializePretty(urs));
        
        
        List<Account> accs = new List<Account>();
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();
        Id coopRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();
        
        Account parentRetailer = TestClass_AccountCreator.BuildRetailer();
        parentRetailer.Record_Sub_Type__c = 'Dual Brand';
        parentRetailer.Name ='DEALER GROUP';
        parentRetailer.record_sub_type__c ='Legal Entity (Dealer Group)';
        insert parentRetailer;
        Account testRetailer = TestClass_AccountCreator.BuildRetailer();    
        testRetailer.Name = urs[1].name.removeEnd(' Partner Manager');
        testRetailer.ParentId = parentRetailer.Id;
        
        Account testRetailer2 = TestClass_AccountCreator.BuildRetailer();    
        testRetailer2.Name = urs[0].name.removeEnd(' Partner Manager');
        testRetailer2.ParentId = parentRetailer.Id;
        accs.add(testRetailer2);
        accs.add(testRetailer);
        insert accs;
        Campaign retailerCampaign = new Campaign(Name='Test Campaign 1', RecordTypeId=retailerRecordTypeId, Retailer__c=testRetailer2.Id);
        insert retailerCampaign;
        
        Test.startTest();
        Campaign coopCampaign = new Campaign(Name='Test child Campaign 1', RecordTypeId=coopRecordTypeId, ParentId=retailerCampaign.Id);
        insert coopCampaign;
        retailerCampaign.Retailer__c = parentRetailer.Id;
        update retailerCampaign;
        Test.stopTest();
        
        List<CampaignShare> cs = [SELECT Id, UserOrGroupId FROM CampaignShare WHERE CampaignId = :coopCampaign.Id AND RowCause = 'Manual'];
        System.assertEquals(2, cs.size());
        
    }
    
    
    
}