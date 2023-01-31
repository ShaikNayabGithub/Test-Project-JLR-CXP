global class AssetVehicleOrderBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id,Name,Status__c,Order_Number__c,Process_Message__c FROM Vista_API_Asset_Align_Record__c where Order_Number__c != null AND Status__c = \'Un Processed\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Vista_API_Asset_Align_Record__c> scope){
        Vista_API_Asset_Align_Record__c assetOrderIns = scope.get(0);
        List<Asset> assetList = [select id,Order_Number__c,VIN__c 
                                 from Asset
                                 where Order_Number__c =: assetOrderIns.Order_Number__c
                                 AND Order_Number__c != null limit 1];
        if(assetList != null && !assetList.isEmpty()){
            Asset AssetIns = assetList.get(0);
            AssetVehicleOrderApiController.AssetWrap wrapIns =  AssetVehicleOrderApiController.handleVehicleOrderApi(AssetIns.Id);
            if(wrapIns != null
               && wrapIns.hasError != null){
                   if(wrapIns.hasError){
                       assetOrderIns.Status__c = 'Error';
                   }else{
                       assetOrderIns.Status__c = 'Processed';
                   }
                   assetOrderIns.Process_Message__c = wrapIns.message;
               }
        }else{
            assetOrderIns.Process_Message__c = 'Asset doesn\'t exist in CXP';
            assetOrderIns.Status__c = 'Error';
        }
        update assetOrderIns; 
    }
    
    global void finish(Database.BatchableContext BC){
    }
}