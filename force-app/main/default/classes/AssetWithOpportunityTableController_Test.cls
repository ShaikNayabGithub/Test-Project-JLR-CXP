@isTest
public class AssetWithOpportunityTableController_Test {
    
    @isTest static void getPicklistValuesTest(){
        AssetWithOpportunityTableController.getPicklistValues('Asset','Common_Order_Type__c');
    }
    @isTest static void handleAssetSearchTestWithOpp(){
        Asset asset = TestClass_AssetBuilder.BuildVehicle(true);
        asset.Vista_Status__c = 'Holding Pool';
        asset.Common_Sale_Type__c = 'Affinity';
        asset.Ordering_Market__c  = 'IC';
        insert asset;
        asset = [SELECT Id, Product2Id FROM Asset WHERE Id = :asset.Id];
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        Product2 prod = [SELECT Id FROM Product2 WHERE Id = :asset.Product2Id];
        PriceBookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(pb, prod);
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Contacted', CloseDate=Date.today(), Pricebook2Id=pb.Id);
        insert opp;
        boolean testSuccess = AssetOppLineItem_LC_Controller.insertOppLineItem(opp.Id, asset.Id);
        List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id AND PricebookEntryId = :pbe.Id];
        List<String> assetStatus = new List<String>{'Holding Pool'};
            List<String> salesType = new List<String>{'Affinity'};
                List<String> isoCodeList = new List<String>{'IN'};
                    AssetWithOpportunityTableController.handleAssetSearch(system.today()-1,system.today()+2,assetStatus,salesType,isoCodeList,'India',null);
    }
    
    @isTest static void handleAssetSearchTestWithOutOpp(){
        Asset asset = TestClass_AssetBuilder.BuildVehicle(true);
        asset.Vista_Status__c = 'Holding Pool';
        asset.Common_Sale_Type__c = 'Affinity';
        asset.Ordering_Market__c  = 'IC';
        insert asset;
        
        List<String> assetStatus = new List<String>{'Holding Pool'};
            List<String> salesType = new List<String>{'Affinity'};
                List<String> isoCodeList = new List<String>{'IN'};
                    AssetWithOpportunityTableController.handleAssetSearch(system.today()-1,system.today()+2,assetStatus,salesType,isoCodeList,'India',null);
    }
    @isTest static void TestLookupSearch(){
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        LookupSearchComponentController.getResults('Account','Name','Test');
    }
}