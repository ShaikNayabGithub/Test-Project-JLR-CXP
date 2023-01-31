public without sharing class AssetTradeInTransferController {
    
    @AuraEnabled
    public static String tradeInAsset(String assetVin, string transactionType) {
        List<Asset> assetsToTradeIn = [SELECT Id,AccountId, VIN__c, Traded_In__c,Retailer_Name__c FROM Asset WHERE VIN__c = :assetVin];
        List<User> loggedInUser = [SELECT Id,contactid,contact.accountid FROM user WHERE id = :UserInfo.getUserId() ];
        
        if(assetsToTradeIn.size() != 1){
            return 'Unable to find Vehicle, please make sure VIN is correct.';
        }
        if(assetsToTradeIn[0].Traded_In__c && assetsToTradeIn[0].AccountId == loggedInUser[0].contact.accountid ){
            return 'VIN is already marked as traded in';
        }
        system.debug('transactionType'+transactionType);
        if(transactionType=='Trade In & Transfer')
        {
        assetsToTradeIn[0].Traded_In__c = true;
        }
        if(loggedInUser[0].contact.accountid != null && assetsToTradeIn[0].AccountId != loggedInUser[0].contact.accountid ){
        	//assetsToTradeIn[0].Retailer_Name__c = loggedInUser[0].contact.accountid;
            assetsToTradeIn[0].AccountId = loggedInUser[0].contact.accountid;
        }
        try{
            update assetsToTradeIn;
        }
        catch(Exception e){
            return e.getMessage();
        }
        return 'Success';
    }
}