public class FinanceUpload_RecordCollection {
    public CSVUpload_DataCollection CSVDataCollection;

    public Map<Integer, Account> AccountsByRowId = new Map<Integer, Account>();
    public Map<Integer, Asset> AssetsByRowId = new Map<Integer, Asset>();    
    public Map<Integer, Contract> ContractsByRowId = new Map<Integer, Contract>();
    public Map<Integer, Service_data__c> ServiceByRowId = new Map<Integer, Service_data__c>();
    public Map<Integer, Service_Data_Item__c> ServiceDataItemsByRowId = new Map<Integer, Service_Data_Item__c>();
    public Map<Id,Set<String>> mapIdAccountToSetVehicles=new Map<Id,Set<String>>();
    public boolean isFileUploadService;
    public boolean isServiceItem;
    public set<String> repairOrdersToProcess;
    public Map<Id,Id> mapAssetIdToRetailerId=new Map<id,id>();
    public Map<Id,Id> mapAccountIdToRetailerId=new Map<id,id>();
    
  
}