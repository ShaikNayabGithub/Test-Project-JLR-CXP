@isTest
public class LocalCampaignBudgetCalculationsLogic_T {
    
    
    @isTest
    static void beforeInsertLogic_Test_LocalPopulatesQuarterOnCoopRetailerWhenQuarterNUllorZero(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP', Local_Amount__c = 10, CurrencyIsoCode = 'GBP');
        
        Test.startTest();
        insert retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Retailer_Quarter_Budget__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.Retailer_Quarter_Budget__c);
    }
    @isTest
    static void beforeInsertLogic_Test_QuarterPopulatesLocalOnCoopRetailerWhenQuarterPopulated(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP', Retailer_Quarter_Budget__c = 10, CurrencyIsoCode = 'GBP');
        
        Test.startTest();
        insert retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Local_Amount__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.Local_Amount__c);
    }
    @isTest
    static void beforeInsertLogic_Test_QuarterPopulatesLocalWhenBothPopulatedOnCoopRetailer(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP',Retailer_Quarter_Budget__c = 100, Local_Amount__c = 10, CurrencyIsoCode = 'GBP');
        
        Test.startTest();
        insert retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Retailer_Quarter_Budget__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(100, retailCampaign.Retailer_Quarter_Budget__c);
    }
     @isTest
    static void beforeInsertLogic_Test_LocalPopulatesBudgetOnCoopWhenBudgetNUllorZero(){
        
        Id COOPRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = COOPRecordTypeId, Local_Currency__c='GBP', Local_Amount__c = 10, CurrencyIsoCode = 'GBP');
        
        Test.startTest();
        insert retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT BudgetedCost FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.BudgetedCost);
    }
    @isTest
    static void beforeInsertLogic_Test_BudgetPopulatesLocalOnCoopWhenPopulated(){
        
        Id COOPRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();      
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = COOPRecordTypeId, Local_Currency__c='GBP', BudgetedCost = 10, CurrencyIsoCode = 'GBP');
        
        Test.startTest();
        insert retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Local_Amount__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.Local_Amount__c);
    }
    @isTest
    static void beforeInsertLogic_Test_BudgetPopulatesLocalWhenBothPopulatedOnCoop(){
        
        Id COOPRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();       
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = COOPRecordTypeId, Local_Currency__c='GBP',BudgetedCost = 100, Local_Amount__c = 10, CurrencyIsoCode = 'GBP');
        
        Test.startTest();
        insert retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT BudgetedCost FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(100, retailCampaign.BudgetedCost);
    }
     @isTest
    static void beforeUpdateLogic_Test_LocalPopulatesQuarterOnCoopRetailerWhenModified(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP',  CurrencyIsoCode = 'GBP');
        insert retailerCampaign1;
        Test.startTest();
        retailerCampaign1.Local_Amount__c = 10;
        update retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Retailer_Quarter_Budget__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.Retailer_Quarter_Budget__c);
    }
    
    @isTest
    static void beforeUpdateLogic_Test_QuarterPopulatesLocalOnCoopRetailerWhenModified(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op_Retailer').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP',  CurrencyIsoCode = 'GBP');
        insert retailerCampaign1;
        Test.startTest();
        retailerCampaign1.Retailer_Quarter_Budget__c= 10;
        update retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Local_Amount__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.Local_Amount__c);
    }
    
    static void beforeUpdateLogic_Test_LocalPopulatesBudgetOnCoopWhenModified(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP',  CurrencyIsoCode = 'GBP');
        insert retailerCampaign1;
        Test.startTest();
        retailerCampaign1.Local_Amount__c = 10;
        update retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT BudgetedCost FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.BudgetedCost);
    }
    
    @isTest
    static void beforeUpdateLogic_Test_BudgetedPopulatesLocalOnCoopWhenModified(){
        
        Id retailerRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Co_Op').getRecordTypeId();        
        
        Campaign retailerCampaign1 = new Campaign(Name = 'Test Campaign 1', RecordTypeId = retailerRecordTypeId, Local_Currency__c='GBP',  CurrencyIsoCode = 'GBP');
        insert retailerCampaign1;
        Test.startTest();
        retailerCampaign1.BudgetedCost= 10;
        update retailerCampaign1;
        Test.stopTest();
        Campaign  retailCampaign = [SELECT Local_Amount__c FROM Campaign WHERE Id = :retailerCampaign1.Id];
        System.assertEquals(10, retailCampaign.Local_Amount__c);
    }
    
    
    
    
}