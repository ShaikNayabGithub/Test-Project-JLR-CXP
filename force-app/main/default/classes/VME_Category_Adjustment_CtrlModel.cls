public class VME_Category_Adjustment_CtrlModel {

    public static Campaign getCampaignRecord(String selectedRegion,String selectedMarket,String selectedYear,String selectedBrand,
                                      String selectedQuarter,String selectedModel, Id vehicleSpecrecordTypeId){
      System.debug(selectedModel);
       Id productrecordTypeId = Schema.Sobjecttype.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId();
      String QMSPOriginalQuery ='SELECT Id,Market_ID__c,CurrencyIsoCode,Name, '+
                'convertCurrency(VME_Under_Over_Run__c),VME_QMSP_Code__c, '+ 
                'EndDate, StartDate, QMSP_Model__c, QMSP_Quarter__c, VME_Brand__c, Market__c, '+
                'VME_Fiscal_Year__c,QMSP_Model__r.Model_Alternative__c ,'+
                'QMSP_Model__r.ProductCode,convertCurrency(VME_Actual_Spent__c), '+
                'convertCurrency(VME_Adjust_Budget__c),convertCurrency(VME_Adjust_P_U_Amount__c),VME_Brand__r.Name, '+
                ' VME_Adjust_volume__c,convertCurrency(VME_Planned_Budget__c),VME_Planned_Volume__c,convertCurrency(VME_Planned_P_U_Amount__c) '+
                'FROM Campaign where Market__c=:selectedRegion AND VME_Fiscal_Year__c=:selectedYear AND '+
                'VME_Brand__r.Name=:selectedBrand AND VME_Brand__r.RecordTypeId =:VehicleSpecrecordTypeId  AND QMSP_Quarter__c=:selectedQuarter';

                           if(selectedModel.contains('(')) {
                                                String finalModel = selectedModel.split(' \\(')[0]; //X152 Model Name
                                                String finalProductCode = selectedModel.split(' \\(')[1].split('\\)')[0]; //W9 Model Product Code
                                                QMSPOriginalQuery+=' AND QMSP_Model__r.Name =\''+finalModel+'\' AND QMSP_Model__r.ProductCode = \''+finalProductCode+'\'';
                                        } else {
                                                String finalModel = selectedModel.split(' \\(')[0];
                                               QMSPOriginalQuery+=' AND QMSP_Model__r.Name =\''+finalModel+'\'';
                                        }
                           QMSPOriginalQuery +=' AND QMSP_Model__r.RecordTypeId=:productrecordTypeId Limit 1';
          Campaign camp = Database.query(QMSPOriginalQuery);
      return camp;
    }


    public static Map<Id,VME_Campaign__c> getVMECampaignMap(String qmpsRecordId,String market){
      Map<Id,VME_Campaign__c> vmeCampMap =new Map<Id,VME_Campaign__c>();
      String QueryData ='Select Id,Name,CurrencyIsoCode,QMSP_Campaign__c,VME_Category__c,VME_End_Date__c,VME_Sub_Category__c,VME_Start_Date__c,VME_External_ID__c,convertCurrency(VME_Actual_Amount__c),convertCurrency(VME_Adjusted_Budget__c),convertCurrency(VME_Adjusted_PU_Amount__c),VME_Adjusted_Volume__c,convertCurrency(VME_Approved_Budget__c),convertCurrency(VME_Approved_PU_Amount__c),VME_Approved_Volume__c,convertCurrency(VME_Planned_Budget__c),convertCurrency(VME_Planned_PU_Amount__c),VME_Planned_Volume__c,convertCurrency(VME_Total_Amount_Approved__c) ,RecordType.Name'+
          ',VME_Model__c,VME_Model__r.Name,VME_Country_ISO_Code__c,VME_L2_Adjustment_Reason__c,VME_Brand__c,RecordTypeId from VME_Campaign__c  where QMSP_Campaign__c=:qmpsRecordId ';
            if(market!='All'){
            QueryData +=' AND VME_Country_ISO_Code__c=:market';
            }
            QueryData +=' ORDER BY VME_End_Date__c DESC';
  
            List<VME_Campaign__c> vmeCampaignList = Database.query(QueryData);
            if(vmeCampaignList !=null && vmeCampaignList.size()>0){
              for(VME_Campaign__c vmeCamp : vmeCampaignList){
                vmeCampMap.put(vmeCamp.Id,vmeCamp);
              }
            }
    
            return vmeCampMap;
    }

    
    public static List<VME_Schemes__c> getSchemeListBasedOnVMECamp(Set<Id> vmeCampaignIdSet){
      Id parentRecordTypeId = VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Parent');
      Id childRecordTypeId =  VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Child');
        return [SELECT Name, CurrencyIsoCode, Id, VME_Start_Date__c, VME_Trade_In__c,VME_End_Date__c, VME_Campaign__c, VME_JLR_Share__c, convertCurrency(VME_PU_Amount__c),  VME_Retailer__c, VME_Consumed_Volume__c, VME_Claims_Approved__c, convertCurrency(VME_Total_Amount_Approved__c), convertCurrency(VME_Total_Amount_Available__c), VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, convertCurrency(VME_Total_VME__c), VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, convertCurrency(VME_Retailer_Contribution__c), VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c,VME_Retailer__r.Name ,RecordTypeId,VME_Segment__c,VME_Sub_Division__c
                       ,(SELECT Id,RecordTypeId FROM  VME_Child_Schemes__r  where VME_InActive__c=false AND recordTypeId=:childRecordTypeId),(SELECT Id FROM  VME_Bundlings__r)
                        from VME_Schemes__c 
                        where VME_Campaign__c IN:vmeCampaignIdSet AND VME_InActive__c=false AND recordTypeId=:parentRecordTypeId
                        ORDER BY VME_Scheme_Type__c DESC];
    }


    public static VME_Campaign__c getVMECampaign(String vmeCampaignId){
        return  [Select Id,Name,CurrencyIsoCode,QMSP_Campaign__c,VME_Category__c,VME_End_Date__c,VME_Sub_Category__c,VME_Start_Date__c,VME_External_ID__c,convertCurrency(VME_Actual_Amount__c),convertCurrency(VME_Adjusted_Budget__c),convertCurrency(VME_Adjusted_PU_Amount__c),VME_Adjusted_Volume__c,convertCurrency(VME_Approved_Budget__c),convertCurrency(VME_Approved_PU_Amount__c),VME_Approved_Volume__c,convertCurrency(VME_Planned_Budget__c),convertCurrency(VME_Planned_PU_Amount__c),VME_Planned_Volume__c,convertCurrency(VME_Total_Amount_Approved__c)
                           ,VME_Model__c,VME_Model__r.Name,VME_Country_ISO_Code__c,VME_Brand__c,VME_L2_Adjustment_Reason__c,RecordType.Name
                        from VME_Campaign__c  
                        where Id=:vmeCampaignId limit 1];
    }


    public static List<VME_Schemes__c> getSchemeListBasedOnScheme(String schemeId, String relVMPECampaignId){
      Id parentRecordTypeId = VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Parent');
      Id childRecordTypeId =  VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Child');
        return [SELECT Name, CurrencyIsoCode, Id, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c,VME_Segment__c,VME_Sub_Division__c,VME_Trade_In__c, VME_JLR_Share__c,VME_Consumed_Volume__c, convertCurrency(VME_PU_Amount__c), VME_Retailer__c, VME_Claims_Available__c, VME_Claims_Approved__c, convertCurrency(VME_Total_Amount_Approved__c), convertCurrency(VME_Total_Amount_Available__c), VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, convertCurrency(VME_Total_VME__c), VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, convertCurrency(VME_Retailer_Contribution__c), VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c,VME_Retailer__r.Name,RecordTypeId
                     ,(SELECT Id,RecordTypeId FROM  VME_Child_Schemes__r where VME_InActive__c=false AND recordTypeId=:childRecordTypeId),(SELECT Id FROM  VME_Bundlings__r)
                    from VME_Schemes__c 
                    where (VME_Campaign__c=:relVMPECampaignId AND VME_InActive__c=false AND recordTypeId=:parentRecordTypeId) 
                    OR Id=:schemeId   
                    ORDER BY VME_Scheme_Type__c DESC];
    }


     public static List<VME_Schemes__c> getSchemeListBasedOnVMECampaign(String vmeCampaignId){
      Id parentRecordTypeId = VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Parent');
      Id childRecordTypeId =  VME_Utility_Class.getRecordTypeId('VME_Schemes__c','Child');
        return [SELECT Name, CurrencyIsoCode, Id, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c,VME_Segment__c,VME_Sub_Division__c,VME_Trade_In__c, VME_JLR_Share__c,convertCurrency(VME_PU_Amount__c),  VME_Retailer__c, VME_Consumed_Volume__c, VME_Claims_Approved__c, convertCurrency(VME_Total_Amount_Approved__c), convertCurrency(VME_Total_Amount_Available__c), VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, convertCurrency(VME_Total_VME__c), VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, convertCurrency(VME_Retailer_Contribution__c), VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c,VME_Retailer__r.Name,RecordTypeId,   
         (SELECT Id,RecordTypeId FROM VME_Child_Schemes__r where VME_InActive__c=false AND recordTypeId=:childRecordTypeId)  ,(SELECT Id FROM  VME_Bundlings__r)
         from VME_Schemes__c 
        where VME_Campaign__c =:vmeCampaignId  AND VME_InActive__c=false AND recordTypeId=:parentRecordTypeId ORDER BY VME_Scheme_Type__c DESC];
    }

     public static List<VME_Schemes__c> getAllChildSchemeList(String parentSchemeId){
        return [SELECT Id,Name,VME_End_Date__c,VME_Start_Date__c,VME_Retailer__c,VME_Retailer__r.Name,RecordTypeId ,VME_InActive__c ,VME_Parent_Scheme__c,VME_Campaign__c,VME_Parent_Scheme__r.VME_Consumed_Volume__c,VME_Parent_Scheme__r.VME_Start_Date__c,VME_Parent_Scheme__r.VME_End_Date__c
     
        from VME_Schemes__c 
        where VME_Parent_Scheme__c =:parentSchemeId  AND VME_InActive__c=false ORDER BY VME_Scheme_Type__c DESC];
    }
    

     public static List<VME_Schemes__c> getUpdatedChildSchemeList(String schemeId, String parentSchemeId){
        return [ SELECT Id,Name,VME_Parent_Scheme__c,VME_Start_Date__c,VME_End_Date__c,VME_Retailer__c,VME_Consumed_Volume__c,VME_Retailer__r.Name,RecordTypeId ,VME_InActive__c,VME_Campaign__c from VME_Schemes__c  where  (VME_InActive__c=false  OR Id=:schemeId ) AND VME_Parent_Scheme__c=: parentSchemeId
                    ORDER BY VME_Scheme_Type__c DESC];
    }

    public static List<VME_Schemes__c> getAllBasedOnVMECampaign(String vmeCampaignId){
    
        return [SELECT Name, CurrencyIsoCode, Id, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c,VME_Trade_In__c, VME_JLR_Share__c,convertCurrency(VME_PU_Amount__c),  VME_Retailer__c, VME_Consumed_Volume__c, VME_Claims_Approved__c, convertCurrency(VME_Total_Amount_Approved__c), convertCurrency(VME_Total_Amount_Available__c), VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, convertCurrency(VME_Total_VME__c), VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, convertCurrency(VME_Retailer_Contribution__c), VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c,VME_Retailer__r.Name,RecordTypeId 
         from VME_Schemes__c 
        where VME_Campaign__c =:vmeCampaignId  AND VME_InActive__c=false  ORDER BY VME_Scheme_Type__c DESC];
    }
public static Decimal getConsumedVolume(String schemeId){
  return [Select id,VME_Consumed_Volume__c from VME_Schemes__c where id=:schemeId].VME_Consumed_Volume__c;
}

}