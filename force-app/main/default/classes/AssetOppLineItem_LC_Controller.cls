public class AssetOppLineItem_LC_Controller {

    @AuraEnabled
    public static boolean insertOppLineItem(Id opportunityId, Id assetId) {
        //need to determine whether asset has a product id
        List<Asset> asset = [SELECT Id, Product2Id, Order_Number__c, Registration_Number__c FROM Asset WHERE Id = :assetId];
        if(asset == null || asset.size() == 0 || asset[0] == null || asset[0].Product2Id == null){
            return false;
        }
        //need to determine which PriceBook to use
        List<Opportunity> opp = [SELECT Id, Pricebook2Id FROM Opportunity WHERE Id = :opportunityId];
        if(opp == null || opp.size() == 0 || opp[0] == null || opp[0].Pricebook2Id == null){
            return false;
        }
        //need to determine whether PriceBook has entry for Asset Product
        List<PriceBookEntry> pbe = [SELECT Id, UnitPrice FROM PriceBookEntry WHERE PriceBook2Id = :opp[0].Pricebook2Id AND Product2Id = :asset[0].Product2Id];
        if(pbe == null || pbe.size() == 0){
            return false;
        }
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp[0].Id, PriceBookEntryId = pbe[0].Id, Quantity = 1, UnitPrice = pbe[0].UnitPrice, Asset__c = asset[0].Id, Vista_Order_Number__c = asset[0].Order_Number__c, Licence_Plate__c = asset[0].Registration_Number__c);
        insert oli;
        return true;
    }
    
}