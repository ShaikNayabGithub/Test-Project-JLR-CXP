public class VME_Category_Adjustment_Ctrl {
        @AuraEnabled
        public static CampaignWrapper getAllQMSPRecords(String selectedRegion, String selectedMarket, String selectedYear, String selectedBrand, String selectedQuarter, String selectedModel) {
                try {
                        Id vehicleSpecrecordTypeId = Schema.Sobjecttype.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
                        List < VMECampaignWrapper > vmeCampaignWrapperList = new List < VMECampaignWrapper > ();
                        Map < Id, VME_Campaign__c > vmeCampMap;
                        Map < Id, List < VME_Schemes__c >> vmeCampaignSchemeMap = new Map < Id, List < VME_Schemes__c >> ();
                        List < VME_Schemes__c > schemesList;
                        Campaign QMSPRecord = VME_Category_Adjustment_CtrlModel.getCampaignRecord(selectedRegion, selectedMarket, selectedYear, selectedBrand, selectedQuarter, selectedModel, vehicleSpecrecordTypeId);
                        if (QMSPRecord != null) vmeCampMap = VME_Category_Adjustment_CtrlModel.getVMECampaignMap(QMSPRecord.Id, selectedMarket);
                      
                        if (vmeCampMap != null && !(vmeCampMap.isEmpty())) {
                                schemesList = VME_Category_Adjustment_CtrlModel.getSchemeListBasedOnVMECamp(vmeCampMap.keySet());
                        }
                        if (schemesList != null && schemesList.size() > 0) {
                                for (VME_Schemes__c sch: schemesList) {
                                        if (vmeCampaignSchemeMap.containsKey(sch.VME_Campaign__c)) {
                                                List < VME_Schemes__c > temp = vmeCampaignSchemeMap.get(sch.VME_Campaign__c);
                                                temp.add(sch);
                                                vmeCampaignSchemeMap.put(sch.VME_Campaign__c, temp);
                                        } else {
                                                vmeCampaignSchemeMap.put(sch.VME_Campaign__c, new List < VME_Schemes__c > {
                                                        sch
                                                });
                                        }
                                }
                        }
                        if (vmeCampMap != null && !(vmeCampMap.isEmpty()))
                                for (VME_Campaign__c VMECampObj: vmeCampMap.values()) {
                                        VMECampaignWrapper vmeCampaignWrapObj = new VMECampaignWrapper();
                                        vmeCampaignWrapObj.vmeCampaignWrap = VMECampObj;
                                        vmeCampaignWrapObj.campEditable = true;
                                        if (vmeCampaignSchemeMap.containsKey(VMECampObj.Id)) {
                                                vmeCampaignWrapObj.schemeList = vmeCampaignSchemeMap.get(VMECampObj.Id);
                                        }
                                        vmeCampaignWrapperList.add(vmeCampaignWrapObj);
                                }
                        CampaignWrapper campaginWrapObj = new CampaignWrapper();
                        campaginWrapObj.campWrap = QMSPRecord;
                        campaginWrapObj.vmeCampaignWrapList = vmeCampaignWrapperList;
                        return campaginWrapObj;
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
        @AuraEnabled
        public static VMECampaignWrapper saveVMERecord(VME_Campaign__c recordData, String methodName) {
                try {
                        VME_Campaign__c vmeCampaignToUpdate = new VME_Campaign__c();
                        vmeCampaignToUpdate.Id = recordData.Id;
                    	system.debug('---> recordData'+recordData.VME_L2_Adjustment_Reason__c);
                      system.debug('---> recordData'+recordData.VME_Adjusted_Volume__c);
                        if (methodName == System.Label.VME_Edit) {
                                vmeCampaignToUpdate.VME_Adjusted_Volume__c = recordData.VME_Adjusted_Volume__c;
                                vmeCampaignToUpdate.VME_Adjusted_PU_Amount__c = VME_Utility_Class.convertCurrencyGBP_to_Other(recordData.VME_Adjusted_PU_Amount__c, UserInfo.getDefaultCurrency(), recordData.CurrencyIsoCode);
                                vmeCampaignToUpdate.VME_L2_Adjustment_Reason__c =recordData.VME_L2_Adjustment_Reason__c;
                                system.debug('--->vmeCampaignToUpdate'+vmeCampaignToUpdate.Id);
                            	update vmeCampaignToUpdate;
                        }
                        VME_Campaign__c updatedVME_Camp = VME_Category_Adjustment_CtrlModel.getVMECampaign(vmeCampaignToUpdate.Id);
                        return endSchemeOnVMECampaignEnd(updatedVME_Camp, methodName);
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        throw new AuraHandledException(e.getMessage());
                }
        }
        @AuraEnabled
        public static VMECampaignWrapper schemeRecordToEnd(VME_Schemes__c schemeToEnd, Boolean isRevised) {
                try {
                        List < VME_Schemes__c > childRecords = VME_Category_Adjustment_CtrlModel.getAllChildSchemeList(schemeToEnd.Id);   
                        List < VME_Schemes__c > schList = new List < VME_Schemes__c > ();
                        VME_Schemes__c schParentObj = new VME_Schemes__c();
                        schParentObj.VME_InActive__c = true;
                        schParentObj.VME_Volume__c = VME_Category_Adjustment_CtrlModel.getConsumedVolume(schemeToEnd.Id);
                        if (isRevised) {
                                schParentObj.VME_Revise_Check__c = true;
                        }
                        if (Date.today() < schemeToEnd.VME_End_Date__c) {
                                schParentObj.VME_End_Date__c = Date.today();
                        } 
                        if (Date.today() < schemeToEnd.VME_Start_Date__c) {
                                schParentObj.VME_Start_Date__c = Date.today();
                        } 
                        if (childRecords != null && childRecords.size() > 0) {
                                for (VME_Schemes__c obj: childRecords) {
                                        VME_Schemes__c schObj = new VME_Schemes__c();
                                        schObj.VME_InActive__c = true;
                                        if (isRevised) {
                                                schObj.VME_Revise_Check__c = true;
                                        }
                                 if (Date.today() < obj.VME_End_Date__c) {
                                schObj.VME_End_Date__c = Date.today();
                        }
                        if (Date.today() < obj.VME_Start_Date__c) {
                                schObj.VME_Start_Date__c = Date.today();
                        }
                                        schObj.Id = obj.Id;
                                        schList.add(schObj);
                                }
                        }
                        schParentObj.Id = schemeToEnd.Id;
                        schList.add(schParentObj);
                        if (schList.size() > 0) update schList;
                        VME_Campaign__c VME_Camp = VME_Category_Adjustment_CtrlModel.getVMECampaign(schemeToEnd.VME_Campaign__c);
                        List < VME_Schemes__c > schemesUpdatedList = VME_Category_Adjustment_CtrlModel.getSchemeListBasedOnScheme(schParentObj.Id, schemeToEnd.VME_Campaign__c);
                        VMECampaignWrapper vmeCampaignWrapObj = new VMECampaignWrapper();
                        vmeCampaignWrapObj.vmeCampaignWrap = VME_Camp;
                        vmeCampaignWrapObj.campEditable = false;
                        vmeCampaignWrapObj.schemeList = schemesUpdatedList;
                        return vmeCampaignWrapObj;
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
        @AuraEnabled
        public static VMECampaignWrapper saveSplitSchemeRecord(VME_Schemes__c schemeToSplit, VME_Schemes__c currentScheme) {
                Savepoint sp = Database.setSavepoint();
                try {
                        List < VME_Schemes__c > upsertList = new List < VME_Schemes__c > ();
                        VME_Schemes__c VMESchemeToUpdate = new VME_Schemes__c();
                        VMESchemeToUpdate.Id = currentScheme.Id;
                        if (!VMESchemeToUpdate.VME_InActive__c) {
                                VMESchemeToUpdate.VME_InActive__c = true;
                        }
                        VMESchemeToUpdate.VME_Revise_Check__c = true;

                             if (Date.today() < currentScheme.VME_End_Date__c) {
                                VMESchemeToUpdate.VME_End_Date__c = Date.today();
                        }
                        if (Date.today() < currentScheme.VME_Start_Date__c) {
                                VMESchemeToUpdate.VME_Start_Date__c = Date.today();
                        }
                        VMESchemeToUpdate.VME_Volume__c = VME_Category_Adjustment_CtrlModel.getConsumedVolume(currentScheme.Id);
                        schemeToSplit.VME_PU_Amount__c = VME_Utility_Class.convertCurrencyGBP_to_Other(schemeToSplit.VME_PU_Amount__c, UserInfo.getDefaultCurrency(), schemeToSplit.CurrencyIsoCode);
                        schemeToSplit.VME_Scheme_Type__c = currentScheme.VME_Scheme_Type__c;
                        upsertList.add(VMESchemeToUpdate);
                        upsertList.add(schemeToSplit);
                        upsert upsertList;
                        VME_Campaign__c VME_Camp = VME_Category_Adjustment_CtrlModel.getVMECampaign(schemeToSplit.VME_Campaign__c);
                        List < VME_Schemes__c > updatedSchemeList = VME_Category_Adjustment_CtrlModel.getSchemeListBasedOnVMECampaign(schemeToSplit.VME_Campaign__c);
                        if (updatedSchemeList != null && updatedSchemeList.size() > 0) {
                                VMECampaignWrapper vmeCampaignWrapObj = new VMECampaignWrapper();
                                vmeCampaignWrapObj.vmeCampaignWrap = VME_Camp;
                                vmeCampaignWrapObj.campEditable = false;
                                vmeCampaignWrapObj.schemeList = updatedSchemeList;
                                return vmeCampaignWrapObj;
                        }
                        return null;
                }
                Catch(Exception e) {
                        Database.rollback(sp);
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
        @AuraEnabled
        public static VMECampaignWrapper endSchemeOnVMECampaignEnd(VME_Campaign__c vmeCampRecord, String methodName) {
                try {
                        List < VME_Schemes__c > VMESchemeList = VME_Category_Adjustment_CtrlModel.getAllBasedOnVMECampaign(VMECampRecord.Id);
               
                        if (methodName == System.Label.VME_End && VMESchemeList != null && VMESchemeList.size() > 0) {
                                List < VME_Schemes__c > updateSchemeList = new List < VME_Schemes__c > ();
                                for (VME_Schemes__c obj: VMESchemeList) {
                                        if (Date.today() < obj.VME_End_Date__c) {
                                                obj.VME_End_Date__c = Date.today();
                                        }
                                        if (Date.today() < obj.VME_Start_Date__c) {
                                                obj.VME_Start_Date__c = Date.today();
                                        }
                                        if (!obj.VME_InActive__c) obj.VME_InActive__c = true;
                                        if(obj.VME_PU_Amount__c !=null)
                                        obj.VME_PU_Amount__c = VME_Utility_Class.convertCurrencyGBP_to_Other(obj.VME_PU_Amount__c, UserInfo.getDefaultCurrency(), obj.CurrencyIsoCode);
                                        updateSchemeList.add(obj);
                                }
                                if (updateSchemeList.size() > 0) update updateSchemeList;
                        }
                        VMECampaignWrapper vmeCampaignWrapObj = new VMECampaignWrapper();
                        vmeCampaignWrapObj.vmeCampaignWrap = vmeCampRecord;
                        vmeCampaignWrapObj.campEditable = false;
                        vmeCampaignWrapObj.schemeList = VME_Category_Adjustment_CtrlModel.getSchemeListBasedOnVMECampaign(vmeCampRecord.Id);
                   
                        return vmeCampaignWrapObj;
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
        @AuraEnabled
        public static String getUserDefaultCurrency() {
                return UserInfo.getDefaultCurrency();
        }
        @AuraEnabled
        public static VME_Campaign__c getCurrentVMECampaign(String recordId) {
                try {
                        return VME_Category_Adjustment_CtrlModel.getVMECampaign(recordId);
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
        @AuraEnabled
        public static VMECampaignWrapper getUpdatedWrapperofCurrentVME(String recordId) {
                try {
                        VMECampaignWrapper vmeCampaignWrapObj = new VMECampaignWrapper();
                        vmeCampaignWrapObj.vmeCampaignWrap = VME_Category_Adjustment_CtrlModel.getVMECampaign(recordId);
                        vmeCampaignWrapObj.campEditable = true;
                        vmeCampaignWrapObj.schemeList = VME_Category_Adjustment_CtrlModel.getSchemeListBasedOnVMECampaign(recordId);
                        return vmeCampaignWrapObj;
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
        @AuraEnabled
        public static Id getRecordTypeOfScheme() {
                return VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Parent');
        }
        @AuraEnabled
        public static List < VME_Schemes__c > getAllRetailerofScheme(String parentSchemeId) {
                        return VME_Category_Adjustment_CtrlModel.getAllChildSchemeList(parentSchemeId);
        }
        @AuraEnabled
        public static List < VME_Schemes__c > getUpdatedChildSchemeList(VME_Schemes__c scheme, String parentSchemeId) {
                try {
                        List < VME_Schemes__c > updateschemeList = new List < VME_Schemes__c > ();
                        List < VME_Schemes__c > schemeChildList = VME_Category_Adjustment_CtrlModel.getAllChildSchemeList(parentSchemeId);
                      
                        Set < Id > childSchemeIds = new Set < Id > ();
                        for (VME_Schemes__c sch: schemeChildList) {
                                childSchemeIds.add(sch.Id);
                        }
                        if(childSchemeIds !=null &&childSchemeIds.size()>0)
                        if (childSchemeIds.size() == 1 && childSchemeIds.contains(scheme.Id)) {
                                VME_Schemes__c updateparentScheme = new VME_Schemes__c();
                                updateparentScheme.Id = parentSchemeId;
                                updateparentScheme.VME_InActive__c = true;
                                    if (Date.today() < schemeChildList[0].VME_Parent_Scheme__r.VME_End_Date__c) {
                                                updateparentScheme.VME_End_Date__c = Date.today();
                                        }
                                        if (Date.today() < schemeChildList[0].VME_Parent_Scheme__r.VME_Start_Date__c) {
                                                updateparentScheme.VME_Start_Date__c = Date.today();
                                        }
                                
                                updateparentScheme.VME_Volume__c = VME_Category_Adjustment_CtrlModel.getConsumedVolume(parentSchemeId);
                                updateschemeList.add(updateparentScheme);
                        }
                        VME_Schemes__c updateScheme = new VME_Schemes__c();
                        updateScheme.Id = scheme.Id;
                        updateScheme.VME_InActive__c = true;
                          if (Date.today() < scheme.VME_End_Date__c) {
                                                updateScheme.VME_End_Date__c = Date.today();
                                        }
                                        if (Date.today() < scheme.VME_Start_Date__c) {
                                                updateScheme.VME_Start_Date__c = Date.today();
                                        }

                        updateschemeList.add(updateScheme);
                        if (updateschemeList.size() > 0) update updateschemeList;
                        return VME_Category_Adjustment_CtrlModel.getUpdatedChildSchemeList( scheme.Id, parentSchemeId);
                }
                Catch(Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getLineNumber());
                        return null;
                }
        }
           @AuraEnabled
           public static Integer getBundeling(VME_Schemes__c scheme,String model){
        // List<VME_Bundling__c> bundelingList=  [Select id,VME_Model_Derivative__c  from VME_Bundling__c where VME_Scheme__c=:scheme.Id  AND  VME_Scheme__r.VME_InActive__c=false];
          Id childRecordTypeId =  VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Child');
          boolean modelwise =false;
         VME_Schemes__c currentSch =[Select id,(Select id,VME_Model_Derivative__c from VME_Bundlings__r), (SELECT Id,RecordTypeId FROM VME_Child_Schemes__r where VME_InActive__c=false AND recordTypeId=:childRecordTypeId)   from VME_Schemes__c where id=:scheme.Id AND  VME_InActive__c=false];
         if(currentSch.VME_Bundlings__r !=null  && (currentSch.VME_Bundlings__r).size()>0  ){
                 for(VME_Bundling__c bund:currentSch.VME_Bundlings__r){
                         if(bund.VME_Model_Derivative__c==model){
                                 modelwise =true;
                                 break;
                         }
                 }
                if(modelwise==true){
                        return 1;
                }else{
                        return 2;
                }
         }else{
          if(currentSch.VME_Child_Schemes__r !=null  && (currentSch.VME_Child_Schemes__r).size()>0  ){
                  return 2;            
     }else{
             return 0;
     }
           }
           }

            @AuraEnabled
           public static String createBundling(String scheme,String model){
            try{
                       List<VME_Bundling__c> existedBundeling  = [Select id,VME_Model_Derivative__c from VME_Bundling__c  where VME_Model_Derivative__c=:model AND  VME_Scheme__c=:scheme];
                if(existedBundeling !=null && existedBundeling.size()>0){
                        return VME_Constants.SUCCESS_MSG;
                }else{
           VME_Bundling__c bundeling =new VME_Bundling__c();
            bundeling.VME_Scheme__c =scheme;
            bundeling.VME_Model_Derivative__c =model;
            insert bundeling;
            return VME_Constants.SUCCESS_MSG;
                          }
            }Catch(Exception e){
                  System.debug(e.getMessage());
                     System.debug(e.getLineNumber());
                     return null;
            }
           }

        @AuraEnabled
        public static Map < String, VME_CXP_Quarter_Info__mdt > getQuarterInfos() {
                return VME_Utility_Class.getQuarterInfos();
        }
        @AuraEnabled
        public static Decimal getAmountConvertedValue(String convertioncode) {
                return VME_Utility_Class.convertCurrencyGBP_to_Other(1, UserInfo.getDefaultCurrency(), convertioncode);
        }
        public class CampaignWrapper {
                @AuraEnabled
                public Campaign campWrap;
                @AuraEnabled
                public List < VMECampaignWrapper > vmeCampaignWrapList;
        }
        public class VMECampaignWrapper {
                @AuraEnabled
                public VME_Campaign__c vmeCampaignWrap;
                @AuraEnabled
                public Boolean campEditable;
                @AuraEnabled
                public List < VME_Schemes__c > schemeList;
        }
}