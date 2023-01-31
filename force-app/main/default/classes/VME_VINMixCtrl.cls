public  class VME_VINMixCtrl {

    @AuraEnabled
    public static List<VME_VINMixCtrlWrapper> getExistingVINForScheme(String schemeId, String parameterName, String revisedSchemeId,String selectedRetailerId){
        return VME_VINMixCtrlService.getExistingVINForScheme(schemeId, parameterName, revisedSchemeId, selectedRetailerId);
    }

    
    @AuraEnabled
    public static List<VME_VINMixCtrlWrapper> getVINBasedOnName( String schemeId, String parameterName, String retailerId,VME_Campaign__c parentVME){
        System.debug(parentVME);
        return VME_VINMixCtrlService.getVINBasedOnName(schemeId, parameterName,retailerId,parentVME);
    }


    @AuraEnabled
    public static String saveVINMixRecords(List<VME_VINMixCtrlWrapper> wrapperList, String schemeId){
        return VME_VINMixCtrlService.saveVINMixRecords(wrapperList, schemeId);
    }

     @AuraEnabled
    public static VME_Category_Adjustment_Ctrl.VMECampaignWrapper getUpdatedWrapperofCurrentVME(String recordId){
     return VME_Utility_Class.getUpdatedWrapperofCurrentVME(recordId);
    }

         @AuraEnabled
    public static  String deleteL3(String schemeId){
      //This is direct delete Hence no need of try catch
      delete [Select id from VME_Schemes__c where VME_Parent_Scheme__c=:schemeId];
      VME_Schemes__c tempVMESch = new VME_Schemes__c();
        tempVMESch.Id =schemeId;
            delete  tempVMESch;

            return VME_Constants.SUCCESS_MSG;
    }

}