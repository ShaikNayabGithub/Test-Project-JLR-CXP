public  class VME_ProductMixCtrlService {
    
   
    
    public static VME_ProductMixFilterWrapper getFilterValues(String schemeId, String revisedSchemeId){
        String modelValue ;
        List<String> modelYearValuesList    = new List<String>();
        List<String> fuelTypeValuesList     = new List<String>();
        List<String> trimValuesList        = new List<String>();
        Map<String,String> engineValuesList       = new  Map<String,String>();
         Map<String,String> doorsValuesList        = new  Map<String,String>();
        List<String> activeValuesList       = new List<String>();

  
        modelYearValuesList.add(VME_Constants.PLEASE_SELECT_VALUE);
        fuelTypeValuesList.add(VME_Constants.PLEASE_SELECT_VALUE);
        trimValuesList.add(VME_Constants.PLEASE_SELECT_VALUE);
        engineValuesList.put(VME_Constants.PLEASE_SELECT_VALUE,VME_Constants.PLEASE_SELECT_VALUE);
        doorsValuesList.put(VME_Constants.PLEASE_SELECT_VALUE,VME_Constants.PLEASE_SELECT_VALUE);

        modelValue = getModelValues(schemeId);
        modelYearValuesList.addAll(getModelYearValuesList());
        fuelTypeValuesList.addAll(getFuelTypeValuesList());
        trimValuesList.addAll(getTrimValuesList());
        engineValuesList.putAll(getEngineValuesList());
        doorsValuesList.putAll(getDoorsValuesList());
        activeValuesList.addAll(getActiveValuesList());
        System.debug(trimValuesList);

        return new VME_ProductMixFilterWrapper(modelValue, modelYearValuesList, fuelTypeValuesList,
                                               trimValuesList, engineValuesList, doorsValuesList, 
                                               activeValuesList, getExistingProductsForScheme(schemeId, revisedSchemeId));
    }


    public static List<VME_ProductMixReqWrapper> searchProducts(String modelValue, String modelYearValue, String fuelTypeValue,
                                      String trimValue, String engineValue, String doorsValue, 
                                      String CountryCode, String parameterName,
                                      String schemeId){
   
        List<VME_ProductMixReqWrapper> reqWrapperList   = new List<VME_ProductMixReqWrapper>();
        List<Product2> productsList     = getSearchedProducts(modelValue, modelYearValue, fuelTypeValue, trimValue,
                                                              engineValue, doorsValue, CountryCode, parameterName);
        if(parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){
            reqWrapperList  =   getReqWrapperListForRevise(reqWrapperList, productsList, schemeId);
        }
        else if(parameterName.equalsIgnoreCase(VME_Constants.MODIFY_VME_MSG)){
            reqWrapperList  =   getReqWrapperListForModify(reqWrapperList, productsList, schemeId);
        }
        else{
            reqWrapperList  =   getReqWrapperListForNew(reqWrapperList, productsList);
        }
        
        return reqWrapperList;
        
    }


    public static String saveProductMixRecords(List<VME_ProductMixReqWrapper> productWrapReqList, String schemeId, String parameterName){
        List<VME_Bundling__c> vmeBundlingList           = new List<VME_Bundling__c>();
        List<VME_Bundling__c> deleteVmeBundlingList     = new List<VME_Bundling__c>();
        for(VME_ProductMixReqWrapper productWrapObj : productWrapReqList){
            if(productWrapObj.isSelected && String.isBlank(productWrapObj.recordId)){
                vmeBundlingList.add(new VME_Bundling__c(VME_Model_Derivative__c = productWrapObj.productObj.Id, VME_Scheme__c = schemeId));
            }else{
                if(String.isNotBlank(productWrapObj.recordId) && productWrapObj.isSelected == false){
                    deleteVmeBundlingList.add(new VME_Bundling__c(Id = productWrapObj.recordId));
                }
                if(productWrapObj.isSelected && String.isNotBlank(productWrapObj.recordId) && parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){
                vmeBundlingList.add(new VME_Bundling__c(VME_Model_Derivative__c = productWrapObj.productObj.Id, VME_Scheme__c = schemeId));
            }
            }
        }
        if(!vmeBundlingList.isEmpty()){
            try{
                insert vmeBundlingList; 
            }catch(Exception e){
                return e.getMessage();
            }
            
        }
        if(!deleteVmeBundlingList.isEmpty()){
            try{
                delete deleteVmeBundlingList;   
            }catch(Exception e){
                return e.getMessage();
            }
            
        }
        return VME_Constants.SUCCESS_MSG;
    }


    static List<VME_ProductMixReqWrapper> getReqWrapperListForRevise(List<VME_ProductMixReqWrapper> reqWrapperList, List<Product2> productsList, String schemeId){
        List<VME_Bundling__c> vmeBundlingList   = new List<VME_Bundling__c>();
        try{
            vmeBundlingList                     = VME_ProductMixCtrlModel.getProductsRelatedToScheme(schemeId);
        
            }catch(Exception e){}
        Map<String,String> productAndBundlingMap    = new Map<String,String>();
        if(!vmeBundlingList.isEmpty()){
            productAndBundlingMap   = prepareProductAndBundlingMap(vmeBundlingList);
        }

        for(Product2 productObj : productsList){
            if(!productAndBundlingMap.isEmpty() && productAndBundlingMap.containsKey(productObj.Id)){
                    reqWrapperList.add(new VME_ProductMixReqWrapper(productObj, true, null));
                }else{
                    reqWrapperList.add(new VME_ProductMixReqWrapper(productObj, false, null));
                }
        }
        return reqWrapperList;
    }


    static List<VME_ProductMixReqWrapper> getReqWrapperListForModify(List<VME_ProductMixReqWrapper> reqWrapperList, List<Product2> productsList, String schemeId){
        List<VME_Bundling__c> vmeBundlingList   = new List<VME_Bundling__c>();
        try{
            vmeBundlingList                     = VME_ProductMixCtrlModel.getProductsRelatedToScheme(schemeId);
   
            }catch(Exception e){}
        Map<String,String> productAndBundlingMap    = new Map<String,String>();
        if(!vmeBundlingList.isEmpty()){
            productAndBundlingMap   = prepareProductAndBundlingMap(vmeBundlingList);
        }

        for(Product2 productObj : productsList){
            if(!productAndBundlingMap.isEmpty() && productAndBundlingMap.containsKey(productObj.Id)){
//                  reqWrapperList.add(new VME_ProductMixReqWrapper(productObj, true, productAndBundlingMap.get(productObj.Id)));
                }else{
                    reqWrapperList.add(new VME_ProductMixReqWrapper(productObj, false, null));
                }
        }

        return reqWrapperList;
    }


    static List<VME_ProductMixReqWrapper> getReqWrapperListForNew(List<VME_ProductMixReqWrapper> reqWrapperList, List<Product2> productsList){
        for(Product2 productObj : productsList){
            reqWrapperList.add(new VME_ProductMixReqWrapper(productObj, false, null));
        }
        return reqWrapperList;
    }


    static Map<String,String> prepareProductAndBundlingMap(List<VME_Bundling__c> vmeBundlingList){
        Map<String,String> productAndBundlingMap    = new Map<String,String>();
        for(VME_Bundling__c budlingObj : vmeBundlingList){
            productAndBundlingMap.put(budlingObj.VME_Model_Derivative__c , budlingObj.Id);
        }
        return productAndBundlingMap;
    }


    static String getModelValues(String schemeId){
        return VME_ProductMixCtrlModel.getVMEScheme(schemeId).VME_Campaign__r.VME_Model__c;
  }


    static List<String> getModelYearValuesList(){
        List<String> modelYear =new List<String>();
        for(Integer i=1;i>=-9;i--){
            modelYear.add(String.valueOf((System.now().addYears(i)).year()));
            
        }
        return  modelYear;
 
    }


    static List<String> getFuelTypeValuesList(){
        return VME_Utility_Class.getAllPickListValue('Product2', 'Fuel_Type_Alternative__c').values();
    }


    static List<String> getTrimValuesList(){
        //return VME_Utility_Class.getTrimMetadata();
        return VME_Utility_Class.getAllPickListValue('Product2', 'Specification_Pack_Alternative__c').values();
    }


    static Map<String,String> getEngineValuesList(){
        return VME_Utility_Class.getAllPickListValue('Product2', 'Engine__c');
    }


    static Map<String,String> getDoorsValuesList(){
        return VME_Utility_Class.getAllPickListValue('Product2', 'Body_Style__c');
    }


    static List<String> getActiveValuesList(){
        return new List<String> {'True', 'False'};
    }


    static List<VME_ProductMixReqWrapper> getExistingProductsForScheme(String schemeId, String revisedSchemeId){
        if(String.isNotBlank(revisedSchemeId)) schemeId     = revisedSchemeId;
        List<VME_ProductMixReqWrapper> exitingProductsList  = new List<VME_ProductMixReqWrapper>();
        List<VME_Bundling__c> existingBundling              = VME_ProductMixCtrlModel.getProductsRelatedToScheme(schemeId);
        List<Product2> productsList                         = new List<Product2>();
        Map<String, String> productAndBundlingMap           = new Map<String, String>();
        for(VME_Bundling__c budlingObj : existingBundling){
            productAndBundlingMap.put(budlingObj.VME_Model_Derivative__c, budlingObj.Id);
        }
        if(!productAndBundlingMap.isEmpty()){
            
            for(Product2 productObj : VME_ProductMixCtrlModel.getProductsDetail(productAndBundlingMap.keySet())){
                exitingProductsList.add(new VME_ProductMixReqWrapper(productObj, true, productAndBundlingMap.get(productObj.Id)));
            }
        }
        return exitingProductsList;
    }


    static List<Product2> getSearchedProducts(String modelValue, String modelYearValue, String fuelTypeValue, 
                                              String trimValue, String engineValue, String doorsValue, 
                                               String CountryCode, String parameterName){
        List<Product2> productsList = new List<Product2>();
        productsList                = buildDynamicQuery(modelValue, modelYearValue, fuelTypeValue, trimValue,
                                                        engineValue, doorsValue, CountryCode);
    
        return productsList;
    }


    static List<Product2> buildDynamicQuery(String modelValue, String modelYearValue, String fuelTypeValue, 
                                    String trimValue, String engineValue, String doorsValue, 
                                     String CountryCode){
         Map<String,String> countryMap =VME_Utility_Class.getCountryISOInfos();
        Integer limitProdMix            = Integer.valueOf(VME_Constants.REC_LIMIT_PRODUCT_MIX);
        String pleaseSelVal             = VME_Constants.PLEASE_SELECT_VALUE;
        String derRecordTypeId          = VME_Utility_Class.getRecordTypeId('Product2', 'Derivative');
        String query                    = 'Select Id, Name, Model_Alternative__c, ProductCode, Make__r.Name, IsActive from Product2 where RecordTypeId =\'' + derRecordTypeId+ '\' ';
        if(String.isNotBlank(modelValue) && !modelValue.equals(pleaseSelVal)){
            //modelValue = '\'%' + modelValue  + '%\' ';
            query   = query + ' AND Model__c=\''+modelValue+'\'';
        }
        if(String.isNotBlank(modelYearValue) && !modelYearValue.equals(pleaseSelVal)){
            modelYearValue = '\'%' + modelYearValue  + '%\' ';
            query   = query + ' AND Name like '+modelYearValue;
        }
        if(String.isNotBlank(fuelTypeValue) && !fuelTypeValue.equals(pleaseSelVal)){
            fuelTypeValue = '\'%' + fuelTypeValue  + '%\' ';
            query   = query + ' AND Name like '+fuelTypeValue;
        }
        if(String.isNotBlank(trimValue) && !trimValue.equals(pleaseSelVal)){
           // trimValue = '\'%' + ' '+trimValue+' '  + '%\' ';
            query   = query + ' AND Specification_Pack_Alternative__c!=null AND Specification_Pack_Alternative__c=\''+trimValue+'\'';
        }
        System.debug(engineValue);
        if(String.isNotBlank(engineValue) && !engineValue.equals(pleaseSelVal)){
            query   = query + ' AND Engine__c !=null AND  Engine__c= \''+engineValue+'\'';
        }
        System.debug(doorsValue);
        if(String.isNotBlank(doorsValue) && !doorsValue.equals(pleaseSelVal)){
            query   = query + ' AND Body_Style__c!=null AND  Body_Style__c =\''+doorsValue+'\'';
        }
            query   = query + ' AND IsActive ='+true;

        if(String.isNotBlank(CountryCode) && !CountryCode.equals(pleaseSelVal)){
  
            CountryCode  = '\'%' + countryMap.get(CountryCode) + '%\' ';
            query   = query + ' AND Market__c!=null AND Market__c like '+CountryCode;
            }
        query = query + ' ORDER BY IsActive DESC LIMIT '+limitProdMix;
        System.debug(query);
        return Database.query(query);

    }
}