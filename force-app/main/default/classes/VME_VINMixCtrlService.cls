public  class VME_VINMixCtrlService {


    public static List<VME_VINMixCtrlWrapper> getExistingVINForScheme(String schemeId, String parameterName, String revisedSchemeId,String selectedRetailerId){
        List<VME_VINMixCtrlWrapper> wrapperList     = new List<VME_VINMixCtrlWrapper>();
        List<Asset> assetList                       = new List<Asset>();
        List<VME_Bundling__c> existingAssetsList    = new List<VME_Bundling__c>();

        if(String.isNotBlank(revisedSchemeId) && parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){         
         schemeId = revisedSchemeId;
        }
        
        existingAssetsList                          = VME_VINMixCtrlModel.getExistingAssetsList(schemeId,selectedRetailerId);
        Map<String,String> assetAndBundleMap        = new Map<String,String>();
        if(!existingAssetsList.isEmpty()){
            assetAndBundleMap   = prepareAssetAndBundleMap(existingAssetsList);
            assetList           = VME_VINMixCtrlModel.getAssetsList(assetAndBundleMap.keySet());
            for(Asset assetObj : assetList){
                if(parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){
                    wrapperList.add(new VME_VINMixCtrlWrapper(assetObj, true, null));
                }
                else if(parameterName.equalsIgnoreCase(VME_Constants.MODIFY_VME_MSG)){
                    wrapperList.add(new VME_VINMixCtrlWrapper(assetObj, true, assetAndBundleMap.get(assetObj.Id)));
                }
            }
        }
        return wrapperList;
    }


    public static List<VME_VINMixCtrlWrapper> getVINBasedOnName(String schemeId, String parameterName,String retailerId,VME_Campaign__c parentVME){
        List<VME_VINMixCtrlWrapper> wrapperList     = new List<VME_VINMixCtrlWrapper>();
        List<Asset> assetList                       = new List<Asset>();
        VME_Schemes__c schemeObj                    = new VME_Schemes__c();
        schemeObj                                   = VME_VINMixCtrlModel.getSchemeDetails(schemeId);
        assetList                                   = VME_VINMixCtrlModel.getAssetsList(retailerId,parentVME);

        if(parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){
            wrapperList     =   getReqWrapperListForRevise(wrapperList, assetList, schemeId,retailerId);
        }
        else if(parameterName.equalsIgnoreCase(VME_Constants.MODIFY_VME_MSG)){
            wrapperList     =   getReqWrapperListForModify(wrapperList, assetList, schemeId,retailerId);
        }
        else{
            wrapperList     =   getReqWrapperListForNew(wrapperList, assetList);
        }

        return wrapperList;
    }


    public static String saveVINMixRecords(List<VME_VINMixCtrlWrapper> wrapperList, String schemeId){
        List<VME_Bundling__c> vmeBundlingList           = new List<VME_Bundling__c>();
        List<VME_Bundling__c> vmeDeleteBundlingList     = new List<VME_Bundling__c>();
        for(VME_VINMixCtrlWrapper vinWrapObj : wrapperList){
            if(vinWrapObj.isSelected && String.isBlank(vinWrapObj.recordId)){
                vmeBundlingList.add(new VME_Bundling__c(Asset__c = vinWrapObj.assetObj.Id, VME_Scheme__c = schemeId));
            }else{
                if(vinWrapObj.isSelected == false && String.isNotBlank(vinWrapObj.recordId)){
                    vmeDeleteBundlingList.add(new VME_Bundling__c(Id = vinWrapObj.recordId));
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

        if(!vmeDeleteBundlingList.isEmpty()){
            try{
                delete vmeDeleteBundlingList;   
            }catch(Exception e){
                return e.getMessage();
            }
            
        }
        return VME_Constants.SUCCESS_MSG;

    }


    static Map<String,String> prepareAssetAndBundleMap(List<VME_Bundling__c> existingAssetsList){
        Map<String,String> assetAndBundleMap    = new Map<String,String>();
        for(VME_Bundling__c bundleObj : existingAssetsList){
            assetAndBundleMap.put(bundleObj.Asset__c , bundleObj.Id);
        }
        return assetAndBundleMap;
    }


    static List<VME_VINMixCtrlWrapper> getReqWrapperListForRevise(List<VME_VINMixCtrlWrapper> reqWrapperList, List<Asset> assetList, String schemeId,String retailerId){
        List<VME_Schemes__c> childSchemesList   = new List<VME_Schemes__c>();
        List<VME_Bundling__c> existingAssetsList    = new List<VME_Bundling__c>();
        existingAssetsList                          = VME_VINMixCtrlModel.getExistingAssetsList(schemeId,retailerId);
        Map<String,String> assetAndBundleMap        = new Map<String,String>();
        
        if(!existingAssetsList.isEmpty()){
            assetAndBundleMap   = prepareAssetAndBundleMap(existingAssetsList);
        }

        for(Asset assetObj : assetList){
            if(!assetAndBundleMap.isEmpty() && assetAndBundleMap.containsKey(assetObj.Id)){
                //  reqWrapperList.add(new VME_VINMixCtrlWrapper(assetObj, true, null));
                }else{
                    reqWrapperList.add(new VME_VINMixCtrlWrapper(assetObj, false, null));
                }
        }
        return reqWrapperList;
    }


    static List<VME_VINMixCtrlWrapper> getReqWrapperListForModify(List<VME_VINMixCtrlWrapper> reqWrapperList, List<Asset> assetList, String schemeId,String retailerId){
        List<VME_Schemes__c> childSchemesList   = new List<VME_Schemes__c>();
        List<VME_Bundling__c> existingAssetsList    = new List<VME_Bundling__c>();
        existingAssetsList                          = VME_VINMixCtrlModel.getExistingAssetsList(schemeId,retailerId);
        Map<String,String> assetAndBundleMap        = new Map<String,String>();

        if(!existingAssetsList.isEmpty()){
            assetAndBundleMap   = prepareAssetAndBundleMap(existingAssetsList);
        }

        for(Asset assetObj : assetList){
            if(!assetAndBundleMap.isEmpty() && assetAndBundleMap.containsKey(assetObj.Id)){
                  //  reqWrapperList.add(new VME_VINMixCtrlWrapper(assetObj, true, assetAndBundleMap.get(assetObj.Id)));
                }else{
                    reqWrapperList.add(new VME_VINMixCtrlWrapper(assetObj, false, null));
                }
        }

        return reqWrapperList;
    }


    static List<VME_VINMixCtrlWrapper> getReqWrapperListForNew(List<VME_VINMixCtrlWrapper> reqWrapperList, List<Asset> assetList){
        for(Asset assetObj : assetList){
            reqWrapperList.add(new VME_VINMixCtrlWrapper(assetObj, false, null));
        }
        return reqWrapperList;
    }
}