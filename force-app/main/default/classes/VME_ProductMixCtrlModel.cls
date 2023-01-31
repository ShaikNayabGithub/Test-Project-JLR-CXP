public  class VME_ProductMixCtrlModel {
    
    public static VME_Schemes__c getVMEScheme(String schemeId){
        return [Select Id, VME_Campaign__r.VME_Model__r.Model_Alternative__c,VME_Campaign__r.VME_Model__c,VME_Campaign__r.VME_Model__r.Name
                from VME_Schemes__c 
                where Id =: schemeId];
    }


    public static List<VME_Bundling__c> getProductsRelatedToScheme(String schemeId){
        return [Select Id, VME_Model_Derivative__c, VME_Scheme__c
                from VME_Bundling__c 
                where VME_Scheme__c =: schemeId AND VME_Model_Derivative__c != null];
    }


    public static List<Product2> getProductsDetail(Set<String> productIdSet){
        return [Select Id, Name, Model_Alternative__c, ProductCode, Make__r.Name, IsActive 
                from Product2 where ID IN: productIdSet];
    }
}