public  class VME_ProductMixCtrl {
    
    @AuraEnabled
    public static VME_ProductMixFilterWrapper getFilterValues(String schemeId, String revisedSchemeId){
        return VME_ProductMixCtrlService.getFilterValues(schemeId, revisedSchemeId);
    }


    @AuraEnabled
    public static List<VME_ProductMixReqWrapper> searchProducts(String modelValue, String modelYearValue, String fuelTypeValue,
                                                String trimValue, String engineValue, String doorsValue
                                                , String CountryCode, String parameterName, String schemeId){
        return VME_ProductMixCtrlService.searchProducts(modelValue, modelYearValue, fuelTypeValue, trimValue,
                                                        engineValue, doorsValue, CountryCode,
                                                        parameterName, schemeId);
    }


    @AuraEnabled
    public static String saveProductMixRecords(List<VME_ProductMixReqWrapper> productWrapReqList, String schemeId, String parameterName){
        return VME_ProductMixCtrlService.saveProductMixRecords(productWrapReqList, schemeId, parameterName);
    }

     @AuraEnabled
    public static VME_Category_Adjustment_Ctrl.VMECampaignWrapper getUpdatedWrapperofCurrentVME(String recordId){
     return VME_Utility_Class.getUpdatedWrapperofCurrentVME(recordId);
    }
}