public  class VME_DealerMixCtrlService {
    

    public static List<VME_DealerMixCtrlWrapper> getExistingDealersForScheme(String schemeId, String parameterName, String revisedSchemeId){
        List<VME_DealerMixCtrlWrapper> wrapperList  = new List<VME_DealerMixCtrlWrapper>();
        List<Account> retailerList                  = new List<Account>();
        List<VME_Schemes__c> childSchemesList       = new List<VME_Schemes__c>();

        if(String.isNotBlank(revisedSchemeId) && parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){         
         schemeId = revisedSchemeId;
        }    System.debug(schemeId);
        childSchemesList                            = VME_DealerMixCtrlModel.getChildSchemesRelatedToScheme(schemeId);

        Map<String,String> accountAndChildSchemeMap     = new Map<String,String>();
        if(!childSchemesList.isEmpty()){
            accountAndChildSchemeMap    = prepareAccountAndChildSchemeMap(childSchemesList);
            retailerList                = VME_DealerMixCtrlModel.getDealersList(accountAndChildSchemeMap.keySet());
            for(Account accountObj : retailerList){
                if(parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){
                    wrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, true, null));
                }
                else if(parameterName.equalsIgnoreCase(VME_Constants.MODIFY_VME_MSG)){
                    wrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, true, accountAndChildSchemeMap.get(accountObj.Id)));
                }
                else{
                //  wrapperList     =   getReqWrapperListForNew(wrapperList, retailerList);
                }
        }
        
        }
        return wrapperList;// VME_DealerMixCtrlService.getDealersBasedOnName(dealerNameSearchValue, schemeId, parameterName);
    }


    public static List<VME_DealerMixCtrlWrapper> getDealersBasedOnName( String schemeId, String parameterName,String countryIsoCode){
        List<VME_DealerMixCtrlWrapper> wrapperList  = new List<VME_DealerMixCtrlWrapper>();
        String retailerRT                           = VME_Utility_Class.getRecordTypeId('Account', 'Retailer');
        List<Account> retailerList                  = new List<Account>();
        retailerList                                = VME_DealerMixCtrlModel.getDealersList(retailerRT, countryIsoCode);
         System.debug('retailerList'+retailerList); 

        if(parameterName.equalsIgnoreCase(VME_Constants.REVISE_VME_MSG)){
            wrapperList     =   getReqWrapperListForRevise(wrapperList, retailerList, schemeId);
        }
        else if(parameterName.equalsIgnoreCase(VME_Constants.MODIFY_VME_MSG)){
            wrapperList     =   getReqWrapperListForModify(wrapperList, retailerList, schemeId);
        }
        else{
            wrapperList     =   getReqWrapperListForNew(wrapperList, retailerList);
        }

        return wrapperList;
    }


    public static String saveDealerMixRecords(List<VME_DealerMixCtrlWrapper> wrapperList, String schemeId, String parameterName ){
        try{

            List<VME_Schemes__c> newSchemeList              = new List<VME_Schemes__c>();
            List<VME_Schemes__c> deleteSchemeList           = new List<VME_Schemes__c>();
            String query                                    = VME_Utility_Class.getDynamQuery('VME_Schemes__c', 'ID =: schemeId');
            VME_Schemes__c schemeObj                        = Database.query(query);
            schemeObj.VME_PU_Amount__c                      = null;
            schemeObj.VME_Volume__c                         = null;
 
            for(VME_DealerMixCtrlWrapper dealerWrapObj : wrapperList){
                if(dealerWrapObj.isSelected && String.isBlank(dealerWrapObj.recordId)){
                    VME_Schemes__c schemeObjNew         = schemeObj.clone();
                    schemeObjNew.VME_Retailer__c        = dealerWrapObj.accountObj.Id;
                    schemeObjNew.VME_Parent_Scheme__c   = schemeObj.Id;
                    schemeObjNew.Name=null;
                    schemeObjNew.VME_External_ID__c =null;
                    schemeObjNew.RecordTypeId           = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Child');
                    newSchemeList.add(schemeObjNew);
                }else{
                    if(dealerWrapObj.isSelected == false && String.isNotBlank(dealerWrapObj.recordId)){
                        deleteSchemeList.add(new VME_Schemes__c(Id = dealerWrapObj.recordId));
                    }
                }
            }
            
            if(!newSchemeList.isEmpty()) insert newSchemeList; 
            if(!deleteSchemeList.isEmpty()) delete deleteSchemeList; 
            return VME_Constants.SUCCESS_MSG;
        }catch(Exception e){
            system.debug('e::::'+e.getLineNumber()+' :::: '+e);
            return e.getMessage();
        }
        
    }


    static List<VME_DealerMixCtrlWrapper> getReqWrapperListForRevise(List<VME_DealerMixCtrlWrapper> reqWrapperList, List<Account> retailerList, String schemeId){
        List<VME_Schemes__c> childSchemesList   = new List<VME_Schemes__c>();
        try{
            childSchemesList                        = VME_DealerMixCtrlModel.getChildSchemesRelatedToScheme(schemeId);
            }catch(Exception e){}
        Map<String,String> accountAndChildSchemeMap     = new Map<String,String>();
        if(!childSchemesList.isEmpty()){
            accountAndChildSchemeMap    = prepareAccountAndChildSchemeMap(childSchemesList);
        }

        for(Account accountObj : retailerList){
            if(!accountAndChildSchemeMap.isEmpty() && accountAndChildSchemeMap.containsKey(accountObj.Id)){
                //  reqWrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, true, null));
                }else{
                    reqWrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, false, null));
                }
        }
        return reqWrapperList;
    }


    static List<VME_DealerMixCtrlWrapper> getReqWrapperListForModify(List<VME_DealerMixCtrlWrapper> reqWrapperList, List<Account> retailerList, String schemeId){
        List<VME_Schemes__c> childSchemesList   = new List<VME_Schemes__c>();
        try{
            childSchemesList                        = VME_DealerMixCtrlModel.getChildSchemesRelatedToScheme(schemeId);
            }catch(Exception e){}
        Map<String,String> accountAndChildSchemeMap     = new Map<String,String>();
        if(!childSchemesList.isEmpty()){
            accountAndChildSchemeMap    = prepareAccountAndChildSchemeMap(childSchemesList);
        }

        for(Account accountObj : retailerList){
            if(!accountAndChildSchemeMap.isEmpty() && accountAndChildSchemeMap.containsKey(accountObj.Id)){
            //      reqWrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, true, accountAndChildSchemeMap.get(accountObj.Id)));
                }else{
                    reqWrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, false, null));
                }
        }

        return reqWrapperList;
    }


    static List<VME_DealerMixCtrlWrapper> getReqWrapperListForNew(List<VME_DealerMixCtrlWrapper> reqWrapperList, List<Account> retailerList){
        for(Account accountObj : retailerList){
            reqWrapperList.add(new VME_DealerMixCtrlWrapper(accountObj, false, null));
        }
        return reqWrapperList;
    }


    static Map<String,String> prepareAccountAndChildSchemeMap(List<VME_Schemes__c> childSchemesList){
        Map<String,String> accountAndChildSchemeMap     = new Map<String,String>();
        for(VME_Schemes__c schemeObj : childSchemesList){
            accountAndChildSchemeMap.put(schemeObj.VME_Retailer__c , schemeObj.Id);
        }
        return accountAndChildSchemeMap;
    }
}