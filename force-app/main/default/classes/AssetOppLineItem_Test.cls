@isTest
public class AssetOppLineItem_Test {

    public static testmethod void Controller_InsertsLineItem_WhenAssetHasProductId() {
        Asset asset = TestClass_AssetBuilder.BuildVehicle(false);
        insert asset;
        asset = [SELECT Id, Product2Id FROM Asset WHERE Id = :asset.Id];
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook();
        Product2 prod = [SELECT Id FROM Product2 WHERE Id = :asset.Product2Id];
        PriceBookEntry pbe = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(pb, prod);
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Contacted', CloseDate=Date.today(), Pricebook2Id=pb.Id);
        insert opp;
        boolean testSuccess = AssetOppLineItem_LC_Controller.insertOppLineItem(opp.Id, asset.Id);
        List<OpportunityLineItem> olis = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id AND PricebookEntryId = :pbe.Id];
        System.assertEquals(1, olis.size());
    }

}