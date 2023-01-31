public  class VME_DealerMixCtrl {
    
    
    @AuraEnabled
    public static List<VME_DealerMixCtrlWrapper> getExistingDealersForScheme(String schemeId, String parameterName, String revisedSchemeId){
        return VME_DealerMixCtrlService.getExistingDealersForScheme(schemeId, parameterName,revisedSchemeId);// VME_DealerMixCtrlService.getDealersBasedOnName(dealerNameSearchValue, schemeId, parameterName);
    }
    
    
    @AuraEnabled
    public static List<VME_DealerMixCtrlWrapper> getDealersBasedOnName(String schemeId, String parameterName, String countryIsoCode){
        return VME_DealerMixCtrlService.getDealersBasedOnName( schemeId, parameterName,countryIsoCode);
    }
    
    
    @AuraEnabled
    public static String saveDealerMixRecords(List<VME_DealerMixCtrlWrapper> wrapperList, String schemeId, String parameterName){
        return VME_DealerMixCtrlService.saveDealerMixRecords(wrapperList, schemeId, parameterName);
    }
    
    @AuraEnabled
    public static  Id getRecordTypeOfVMEDiscreationary(){
        return VME_Utility_Class.getRecordTypeId('VME_Campaign__c','Discretionary');
    }
    @AuraEnabled
    public static  String deleteL3(String schemeId){
        //This is direct delete Hence no need of try catch
        VME_Schemes__c tempVMESch = new VME_Schemes__c();
        tempVMESch.Id =schemeId;
        delete  tempVMESch;
        return VME_Constants.SUCCESS_MSG;
        
        
    }
    @AuraEnabled
    public static String loggedInFormat(){
        return VME_Utility_Class.getUserDateTimeFormat();
    }
    
    @AuraEnabled
    public static VME_Category_Adjustment_Ctrl.VMECampaignWrapper getUpdatedWrapperofCurrentVME(String recordId){
        return VME_Utility_Class.getUpdatedWrapperofCurrentVME(recordId);
    }
    
    @AuraEnabled
    public static String relatedBundling(String scheme,String model, Boolean deleteBundel){
        try{
            System.debug(scheme);
            List<VME_Bundling__c> existedBundeling  = [Select id,VME_Model_Derivative__c from VME_Bundling__c  where VME_Model_Derivative__c=:model AND  VME_Scheme__c=:scheme];
            
            if(existedBundeling !=null && existedBundeling.size()>0){
                if(deleteBundel){
                    delete existedBundeling;
                }
                return VME_Constants.SUCCESS_MSG;
            }else{
                if(!deleteBundel){
                    VME_Bundling__c bundeling =new VME_Bundling__c();
                    bundeling.VME_Scheme__c =scheme;
                    bundeling.VME_Model_Derivative__c =model;
                    insert bundeling;
                }
                return VME_Constants.SUCCESS_MSG;
            }
        }Catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
            return null;
        }
    }
    
}