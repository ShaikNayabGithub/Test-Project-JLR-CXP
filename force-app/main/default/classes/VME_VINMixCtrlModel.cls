public  class VME_VINMixCtrlModel {

    
    public static List<VME_Bundling__c> getExistingAssetsList(String schemeId, String selectedRetailerId){
        System.debug(selectedRetailerId);
        List< VME_Bundling__c> deleteList = new  List< VME_Bundling__c>();
        List<VME_Bundling__c> relatedbundList = new  List<VME_Bundling__c>();
        List<VME_Bundling__c> bundList = [Select Id, Asset__c, VME_Scheme__c ,Asset__r.Retailer_Name__c
                from VME_Bundling__c
                where VME_Scheme__c =: schemeId];
                if(bundList!=null && bundList.size()>0){
                    for(VME_Bundling__c bund :bundList){
                           System.debug(bund.Asset__r.Retailer_Name__c);
                        if(bund.Asset__r.Retailer_Name__c!=selectedRetailerId){
                                deleteList.add(bund);
                        }else{
                            relatedbundList.add(bund);
                        }
                    }
                }
                if(deleteList !=null && deleteList.size()>0){
                    delete deleteList;
                }
                return relatedbundList;
    }


    public static List<Asset> getAssetsList(Set<String> assetIdSet){
        return [Select Id, Brand__r.Name, Model__r.Name, VIN__c, Model_Year__c,Retailer_Name__c
                from Asset
                where Id IN: assetIdSet];
    }


    public static List<Asset> getAssetsList(String retailerId,VME_Campaign__c parentVME){
          Id parentRecordTypeId = VME_Utility_Class.getRecordTypeId('Asset','Vehicle');
        return [Select Id, Brand__r.Name, Model__r.Name, VIN__c,Model_Year__c,Retailer_Name__c
                from Asset
                where VIN__c!=null AND Brand__c != null  AND Model__c!= null AND Brand__c=:parentVME.VME_Brand__c AND Model__c=: parentVME.VME_Model__c AND Retailer_Name__c != null  AND Retailer_Name__c=: retailerId AND VME_Retail_Date__c=null AND RecordTypeId=:parentRecordTypeId];
    }


    public static VME_Schemes__c getSchemeDetails(String schemeId){
        return [Select Id, VME_Campaign__r.VME_Model__r.Name, VME_Campaign__r.VME_Brand__r.Name 
                from VME_Schemes__c 
                where Id =: schemeId];
    }
}