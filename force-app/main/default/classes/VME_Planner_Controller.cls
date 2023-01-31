/*--
||      Name : VME_Planner_Controller.apxc
||      Author: Sumit Kumar
||      Purpose: VME Planner controller to get the data from Salesforce and perform thr DML int it.
||      Created Date : 15/04/2018
||      Modified By: <Your name>
||      Modified Date : Date
||      Reason : <your reason>
--*/
public class VME_Planner_Controller {
        static String VEHICLE_SPECIFICATION_MAKE='Make';
        static String QMSP_VME_RECORDTYPE='QMSP';
        public static final Id PARENT_SCHEME_RECORD_TYPE = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Parent');
        public static final Id CHILD_SCHEME_RECORD_TYPE = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Child');

        public VME_Planner_Controller() {}

        @AuraEnabled public static user fetchUser() {
                // query current user information
                // commented as the class throwing error
                //User loggedUser=VME_Utility_Class.fetchUser();
                // query current user information  
                User loggedUser = [SELECT id,Name,TimeZoneSidKey,Username,Market__c,Country,Email,FirstName,LastName,IsActive,User_Status__c, Sales_Region__c,LocaleSidKey,LanguageLocaleKey, CurrencyIsoCode, DefaultCurrencyIsoCode, Country_ISO_Code__c FROM User WHERE id =: UserInfo.getUserId()];
                //putting used based local locale value and date format
                loggedUser.CPF__c = VME_Utility_Class.getUserDateTimeFormat();
                return loggedUser;
        }

        @AuraEnabled public static Map<String,
        List<String>>getRegion_Market_Map() {
                sObject USER_Obj=Schema.getGlobalDescribe().get('User').newSObject();
            	//getting Market and Country from User field
                Map < String, List < String>>getRegion_Market_Map=VME_Utility_Class.getDependentPicklist(USER_Obj, 'Market__c', 'Country_ISO_Code__c');//Campaign Market_Id__c
                //System.debug(getRegion_Market_Map);
                return getRegion_Market_Map;
        }

        @AuraEnabled public static Map<String, List<String>>getBrand_Model_Map() {
                return VME_Utility_Class.getVMEBrandModelRealData();
        }

        //Getting all the VME Planner Filters Value
        @AuraEnabled public static Map<String, Map<String, String>>getFiltersValues() {
                //creating a map which will hold all the field list values in map
                Map<String,Map<String,String>>mapOfFilterValues=new Map<String,Map<String,String>>();
                //Below snippet is for getting all Category List from Utility
                mapOfFilterValues.put('Category', VME_Utility_Class.getAllPickListValue('VME_Campaign__c', 'VME_Category__c'));
                //Below snippet is for getting all FISCAL year List from Utility
                mapOfFilterValues.put('Fiscal_Year', VME_Utility_Class.getAllPickListValue('Campaign', 'VME_Fiscal_Year__c'));
                //Below snippet is for getting all Quarter year List from Utility
                mapOfFilterValues.put('Quarter', VME_Utility_Class.getAllPickListValue('Campaign', 'QMSP_Quarter__c'));
                //System.debug(mapOfRegions);   
                return mapOfFilterValues;
        }

        @AuraEnabled public static VME_Planner_Wrapper getMasterQMSPData(Map<String, String> selectedFilterValues, String userISOCode) {
                //Master Wrapper Initialization
                VME_Planner_Wrapper masterWrapper=new VME_Planner_Wrapper();
                masterWrapper.statusOfTransaction='NO-FILTER';
                masterWrapper.errorMsgOfTransaction='No Error';
                System.debug('selectedFilterValues >> '+selectedFilterValues);

                try {
                        //Query Building Starts here
                        //getting the recoprdtype of Make type in vehicle specification
                        Id QMSPRecordTypeId=Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(QMSP_VME_RECORDTYPE).getRecordTypeId();
                        //getting QMSP Query and QMSP Record
                        String QMSPOriginalQuery='SELECT Id, Name, RecordTypeId, StartDate, EndDate, CurrencyIsoCode, IsActive, OwnerId, Country__c, Market__c, Market_ID__c, VME_Brand__c, VME_Brand__r.Name, QMSP_Quarter__c, QMSP_Model__c, QMSP_Model__r.Name, QMSP_Model__r.ProductCode, VME_QMSP_Code__c, VME_Actual_Spent__c, convertCurrency(VME_Actual_Spent__c) VME_Actual_Spent, VME_Fiscal_Year__c, VME_Adjust_P_U_Amount__c, convertCurrency(VME_Adjust_P_U_Amount__c) VME_Adjust_P_U_Amount, VME_Adjust_volume__c, VME_Actual_Volume__c, VME_Adjust_Budget__c, convertCurrency(VME_Adjust_Budget__c) VME_Adjust_Budget, VME_Under_Over_Run__c, convertCurrency(VME_Under_Over_Run__c) VME_Under_Over_Run, VME_Approved_Budget__c, convertCurrency(VME_Approved_Budget__c) VME_Approved_Budget, VME_Approved_Volume__c, VME_Approved_P_U_Amount__c, convertCurrency(VME_Approved_P_U_Amount__c) VME_Approved_P_U_Amount, VME_Planned_Volume__c, VME_Planned_Budget__c, convertCurrency(VME_Planned_Budget__c) VME_Planned_Budget, VME_Planned_P_U_Amount__c, convertCurrency(VME_Planned_P_U_Amount__c) VME_Planned_P_U_Amount, VME_Retail_P_U__c, convertCurrency(VME_Retail_P_U__c) VME_Retail_P_U,VME_Retail_Volume__c FROM Campaign WHERE RecordTypeId =: QMSPRecordTypeId';
  						
                        //VME Planner filter logic goes here
                        for(String filterKey: selectedFilterValues.keySet()) {
                                String filterValue=selectedFilterValues.get(filterKey);

                                if(filterKey=='Region'&& filterValue !='Select_Region') {
                                        if(filterValue !='All_Region') QMSPOriginalQuery+=' AND Market__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Country'&& filterValue !='Select_Country') {
                                        /*if(filterValue !='All_Country') QMSPOriginalQuery+=' AND Market_ID__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';*/
                                } else if(filterKey=='Brand'&& filterValue !='Select_Brand') {
                                        if(filterValue !='All_Brand') QMSPOriginalQuery+=' AND VME_Brand__r.Name =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Model'&& filterValue !='Select_Model') {
                                        //System.debug('Model ::: ' + filterValue);//X152 (W9)
                                        if(filterValue.contains('(')) {
                                                String finalModel = filterValue.split(' \\(')[0]; //X152 Model Name
                                                String finalProductCode = filterValue.split(' \\(')[1].split('\\)')[0]; //W9 Model Product Code
                                                QMSPOriginalQuery+=' AND QMSP_Model__r.Name =\''+finalModel+'\' AND QMSP_Model__r.ProductCode = \''+finalProductCode+'\'';
                                        } else {
                                                String finalModel = filterValue.split(' \\(')[0];
                                                if(filterValue !='All_Model') QMSPOriginalQuery+=' AND QMSP_Model__r.Name =\''+finalModel+'\'';
                                        }
                                        //System.debug('Model Query ::: ' + QMSPOriginalQuery);
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Fiscal_Year'&& filterValue !='Select_Fiscal Year') {
                                        QMSPOriginalQuery+=' AND VME_Fiscal_Year__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Quarter'&& filterValue !='Select_Quarter') {
                                        if(filterValue !='All_Quarter') QMSPOriginalQuery+=' AND QMSP_Quarter__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else {}
                        }

                        System.debug(QMSPOriginalQuery);
                        //System.debug([SELECT RecordTypeId, Market__c, Market_ID__c, QMSP_Model__r.Name, VME_Financial_Year__c, VME_Brand__r.Name, QMSP_Quarter__c FROM Campaign]);
                        List<Campaign>QMSPList=Database.Query(QMSPOriginalQuery);
                        System.debug(QMSPList);
                        //getting VME Query and QMSP Record
                       String VMEOriginalQuery='SELECT Id, Name, CurrencyIsoCode, RecordTypeId, VME_Brand__c, VME_Brand__r.Name, VME_End_Date__c, VME_External_ID__c, VME_Model__c, VME_Model__r.Name, VME_Model__r.ProductCode, VME_Quarter__c, QMSP_Campaign__c, VME_Start_Date__c, VME_Category__c, VME_Sub_Category__c, VME_Actual_Amount__c, convertCurrency(VME_Actual_Amount__c) VME_Actual_Amount, VME_Fiscal_Year__c, VME_Market_Code__c, VME_Country_ISO_Code__c, VME_Country__c, VME_Approved_Budget__c, convertCurrency(VME_Approved_Budget__c) VME_Approved_Budget, VME_Approved_Volume__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, convertCurrency(VME_Total_Amount_Approved__c) VME_Total_Amount_Approved, VME_Approved_PU_Amount__c, convertCurrency(VME_Approved_PU_Amount__c) VME_Approved_PU_Amount, VME_Adjusted_Volume__c, VME_Planned_Budget__c, convertCurrency(VME_Planned_Budget__c) VME_Planned_Budget, VME_Planned_Volume__c, VME_Planned_PU_Amount__c, convertCurrency(VME_Planned_PU_Amount__c) VME_Planned_PU_Amount, VME_Adjusted_Budget__c, convertCurrency(VME_Adjusted_Budget__c) VME_Adjust_Budget, VME_Adjusted_PU_Amount__c, convertCurrency(VME_Adjusted_PU_Amount__c) VME_Adjust_PU_Amount, (SELECT Id, Name, CurrencyIsoCode, VME_Start_Date__c, VME_End_Date__c, VME_Campaign__c, VME_JLR_Share__c, VME_PU_Amount__c, convertCurrency(VME_PU_Amount__c) VME_PU_Amount, VME_Retailer__c, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, convertCurrency(VME_Total_Amount_Approved__c) VME_Total_Amount_Approved, VME_Total_Amount_Available__c, convertCurrency(VME_Total_Amount_Available__c) VME_Total_Amount_Available, VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, VME_Total_VME__c, convertCurrency(VME_Total_VME__c) VME_Total_VME, VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, VME_Retailer_Contribution__c, convertCurrency(VME_Retailer_Contribution__c) VME_Retailer_Contribution, VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c, VME_Type__c FROM VME_Schemes__r WHERE RecordTypeId =: PARENT_SCHEME_RECORD_TYPE) FROM VME_Campaign__c WHERE QMSP_Campaign__c IN: QMSPList';
 					
                        //VME Level Filter Checking
                        if(selectedFilterValues.get('Category') !='Select_Category') {
                                VMEOriginalQuery+=' AND VME_Category__c =\''+selectedFilterValues.get('Category')+'\'';
                        }
                        if(selectedFilterValues.get('Country') !='Select_Country') {
                                if(selectedFilterValues.get('Country') !='All_Country') VMEOriginalQuery+=' AND VME_Country_ISO_Code__c =\''+selectedFilterValues.get('Country')+'\'';
                        } 
                        if(selectedFilterValues.get('VME_Type') !='Select_VME-Type') {
                                //getting the recoprdtype of Make type in vehicle specification
                                Id VMERecordTypeId=Schema.SObjectType.VME_Campaign__c.getRecordTypeInfosByName().get(selectedFilterValues.get('VME_Type')).getRecordTypeId();
                                VMEOriginalQuery+=' AND RecordTypeId =\''+VMERecordTypeId+'\'';
                        }
                        System.debug('VMEOriginalQuery :: '+ VMEOriginalQuery);
                        List<VME_Campaign__c>vme_Campaign_List=Database.Query(VMEOriginalQuery);
                        System.debug(vme_Campaign_List);
                        //Querying Schemes from VME List
                        String SchemeOriginalQuery='SELECT Id, Name, CurrencyIsoCode, VME_Start_Date__c, RecordTypeId, RecordType.Name, VME_End_Date__c, VME_Campaign__r.VME_Model__c, VME_Campaign__r.VME_Model__r.Name, VME_Campaign__c, VME_Campaign__r.QMSP_Campaign__c, VME_JLR_Share__c, VME_PU_Amount__c, convertCurrency(VME_PU_Amount__c) VME_PU_Amount, VME_Retailer__c, VME_Retailer__r.Name, VME_Claims_Available__c, VME_Claims_Approved__c, VME_Total_Amount_Approved__c, convertCurrency(VME_Total_Amount_Approved__c) VME_Total_Amount_Approved, VME_Total_Amount_Available__c, convertCurrency(VME_Total_Amount_Available__c) VME_Total_Amount_Available, VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, VME_Total_VME__c, convertCurrency(VME_Total_VME__c) VME_Total_VME, VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, VME_Retailer_Contribution__c, convertCurrency(VME_Retailer_Contribution__c) VME_Retailer_Contribution, VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c, VME_Type__c, (SELECT Id, VME_Retailer__c, VME_Retailer__r.Name FROM VME_Child_Schemes__r WHERE RecordTypeId =: CHILD_SCHEME_RECORD_TYPE), (SELECT Id, VME_Model_Derivative__c,VME_Model_Derivative__r.Name, VME_Model_Derivative__r.Model__r.Name, VME_Model_Derivative__r.Make__r.Name, VME_Model_Derivative__r.Model__c, VME_Model_Derivative__r.Make__c FROM VME_Bundlings__r) FROM VME_Schemes__c WHERE RecordTypeId =: PARENT_SCHEME_RECORD_TYPE AND  VME_Campaign__c IN: vme_Campaign_List';
                     
                    List<VME_Schemes__c>vme_Scheme_List=Database.Query(SchemeOriginalQuery);
                        System.debug(vme_Scheme_List);
                        String BundlingOriginalQuery='SELECT Id, Name, CurrencyIsoCode, VME_Model_Derivative__c, VME_Model_Derivative__r.Model__r.Name, VME_Model_Derivative__r.Make__r.Name, VME_Model_Derivative__r.Model__c, VME_Model_Derivative__r.Make__c,VME_Scheme__c,VME_Scheme__r.Name, Asset__c, Asset__r.Name, Asset__r.VIN__c FROM VME_Bundling__c WHERE VME_Scheme__c IN: vme_Scheme_List';
                        List<VME_Bundling__c>vme_Bundling_List=Database.Query(BundlingOriginalQuery);
                        System.debug(vme_Bundling_List);
                        //Iteration for Second level of Wrapper for VMEs and List of Sche,mes
                        Map<Id, VME_Bundling__c>temporaryScheme_Bundling_Map=new Map<Id, VME_Bundling__c>();

                        for (VME_Bundling__c vme_Bundling : vme_Bundling_List) {
                                temporaryScheme_Bundling_Map.put(vme_Bundling.VME_Scheme__c, vme_Bundling);
                        }

                        //Iteration for Second level of Wrapper for VMEs and List of Sche,mes
                        Map<Id, List<VME_Schemes__c>>temporaryVME_Scheme_Map=new Map<Id,List<VME_Schemes__c>>();
                        //Map to store total Approved amound based on each QMSP
                        Map<String, Decimal>QMSP_TotalAprrovedClaim_Map=new Map<String, Decimal>(); //VME_Campaign__r.QMSP_Campaign__c

                        for(VME_Schemes__c schemeTemp: vme_Scheme_List) {
                                if( !temporaryVME_Scheme_Map.containsKey(schemeTemp.VME_Campaign__c)) {
                                        temporaryVME_Scheme_Map.put(schemeTemp.VME_Campaign__c, new List<VME_Schemes__c> { schemeTemp });
                                } else {
                                        List<VME_Schemes__c>tempSchemeList=temporaryVME_Scheme_Map.get(schemeTemp.VME_Campaign__c);
                                        tempSchemeList.add(schemeTemp);
                                        temporaryVME_Scheme_Map.put(schemeTemp.VME_Campaign__c, tempSchemeList);
                                }

                                if( !QMSP_TotalAprrovedClaim_Map.containsKey(schemeTemp.VME_Campaign__r.QMSP_Campaign__c)) {
                                        QMSP_TotalAprrovedClaim_Map.put(schemeTemp.VME_Campaign__r.QMSP_Campaign__c, schemeTemp.VME_Total_Amount_Approved__c);
                                } else {
                                        Decimal tempApprovedAmount=QMSP_TotalAprrovedClaim_Map.get(schemeTemp.VME_Campaign__r.QMSP_Campaign__c);
                                        tempApprovedAmount+=schemeTemp.VME_Total_Amount_Approved__c;
                                        QMSP_TotalAprrovedClaim_Map.put(schemeTemp.VME_Campaign__r.QMSP_Campaign__c, tempApprovedAmount);
                                }
                        }

                        //Iteration for First level of Wrapper for QMSP and List of VMEs
                        Map<Id, List<VME_Wrapper>>QMSP_VME_Mapping=new Map<Id, List<VME_Wrapper>>();
                        //Map to store total Approved amound based on each QMSP
                        Map<String, Decimal>QMSP_ActualVMEAmount_Map=new Map<String, Decimal>();
                        Set<Id>vme_QMSP_IdSet=new Set<Id>();

                        for(VME_Campaign__c vmeTemp: vme_Campaign_List) {
                                VME_Wrapper tempVMEWrap=new VME_Wrapper(vmeTemp, temporaryVME_Scheme_Map.get(vmeTemp.Id));
                                vme_QMSP_IdSet.add(vmeTemp.QMSP_Campaign__c);

                                if( !QMSP_VME_Mapping.containsKey(vmeTemp.QMSP_Campaign__c)) {
                                        QMSP_VME_Mapping.put(vmeTemp.QMSP_Campaign__c, new List<VME_Wrapper> { tempVMEWrap });
                                } else {
                                        List<VME_Wrapper>tempVMEWrapList=QMSP_VME_Mapping.get(vmeTemp.QMSP_Campaign__c);
                                        tempVMEWrapList.add(tempVMEWrap);
                                        QMSP_VME_Mapping.put(vmeTemp.QMSP_Campaign__c, tempVMEWrapList);
                                }
                        }

                        //Iterating for Master Wrapper Data
                        List<QMSP_Wrapper>QMSP_Wrapper_List=new List<QMSP_Wrapper>();
                        
                        for(Campaign QMSPObj: QMSPList) {
                                //System.debug(QMSPObj.get('VME_Approved_Budget'));
                                Decimal final_Approved_Amount=QMSP_TotalAprrovedClaim_Map.get(QMSPObj.Id) !=null ? QMSP_TotalAprrovedClaim_Map.get(QMSPObj.Id): 0.00;
                                final_Approved_Amount=VME_Utility_Class.convertCurrencyGBP_to_Other(final_Approved_Amount, QMSPObj.CurrencyIsoCode, userISOCode);
                                String underOverRunNotification='Grey';
                                //System.debug('QMSPObj.VME_Under_Over_Run__c :: '+ QMSPObj.VME_Under_Over_Run__c);
                                if(QMSPObj.VME_Under_Over_Run__c < 0) {
                                        underOverRunNotification='Red';
                                } else if(QMSPObj.VME_Under_Over_Run__c > 0) {
                                        underOverRunNotification='Green';
                                } else {}

                                if(selectedFilterValues.get('Category') !='Select_Category'|| selectedFilterValues.get('VME_Type') !='Select_VME-Type') {
                                        if(vme_QMSP_IdSet.contains(QMSPObj.Id)) {
                                                QMSP_Wrapper newQMSPWrapper=new QMSP_Wrapper(QMSPObj, QMSP_VME_Mapping.get(QMSPObj.Id), final_Approved_Amount, underOverRunNotification);
                                                QMSP_Wrapper_List.add(newQMSPWrapper);
                                        }
                                }
                                else {
                                        QMSP_Wrapper newQMSPWrapper=new QMSP_Wrapper(QMSPObj, QMSP_VME_Mapping.get(QMSPObj.Id), final_Approved_Amount, underOverRunNotification);
                                        QMSP_Wrapper_List.add(newQMSPWrapper);
                                }
                        }


                        //getting QMSP Query and QMSP Record
                        String QMSPBWPQuery='SELECT Id, Name, RecordTypeId, StartDate, EndDate, CurrencyIsoCode, IsActive, OwnerId, Country__c, Market__c, Market_ID__c, VME_Brand__c, VME_Brand__r.Name, QMSP_Quarter__c, QMSP_Model__c, QMSP_Model__r.Name, QMSP_Model__r.ProductCode, VME_QMSP_Code__c, VME_Actual_Spent__c, convertCurrency(VME_Actual_Spent__c) VME_Actual_Spent, VME_Fiscal_Year__c, VME_Adjust_P_U_Amount__c, convertCurrency(VME_Adjust_P_U_Amount__c) VME_Adjust_P_U_Amount, VME_Adjust_volume__c, VME_Actual_Volume__c, VME_Adjust_Budget__c, convertCurrency(VME_Adjust_Budget__c) VME_Adjust_Budget, VME_Under_Over_Run__c, convertCurrency(VME_Under_Over_Run__c) VME_Under_Over_Run, VME_Approved_Budget__c, convertCurrency(VME_Approved_Budget__c) VME_Approved_Budget, VME_Approved_Volume__c, VME_Approved_P_U_Amount__c, convertCurrency(VME_Approved_P_U_Amount__c) VME_Approved_P_U_Amount, VME_Planned_Volume__c, VME_Planned_Budget__c, convertCurrency(VME_Planned_Budget__c) VME_Planned_Budget, VME_Planned_P_U_Amount__c, convertCurrency(VME_Planned_P_U_Amount__c) VME_Planned_P_U_Amount FROM Campaign WHERE RecordTypeId =: QMSPRecordTypeId';
					   //VME Planner filter logic goes here
                        for(String filterKey: selectedFilterValues.keySet()) {
                                String filterValue=selectedFilterValues.get(filterKey);

                                if(filterKey=='Region'&& filterValue !='Select_Region') {
                                        if(filterValue !='All_Region') QMSPBWPQuery+=' AND Market__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Brand'&& filterValue !='Select_Brand') {
                                        if(filterValue !='All_Brand') QMSPBWPQuery+=' AND VME_Brand__r.Name =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Fiscal_Year'&& filterValue !='Select_Fiscal Year') {
                                        QMSPBWPQuery+=' AND VME_Fiscal_Year__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } else if(filterKey=='Quarter'&& filterValue !='Select_Quarter') {
                                        if(filterValue !='All_Quarter') QMSPBWPQuery+=' AND QMSP_Quarter__c =\''+filterValue+'\'';
                                        masterWrapper.statusOfTransaction='SUCCESS';
                                } 
                        }

                        System.debug(QMSPBWPQuery);
                        //System.debug([SELECT RecordTypeId, Market__c, Market_ID__c, QMSP_Model__r.Name, VME_Financial_Year__c, VME_Brand__r.Name, QMSP_Quarter__c FROM Campaign]);
                        List<Campaign> QMSPBWPList=Database.Query(QMSPBWPQuery);
                        //System.debug(QMSPBWPList);

                        //Brand Wise report builder 
                        BrandWiseQuarterPlanWrapper BrandWiseQuarterPlan_Wrapper = new BrandWiseQuarterPlanWrapper();
                        Map<String, CampaignShadowObject> brandWiseObject = new Map<String, CampaignShadowObject>();

                        for(Campaign QMSPObj: QMSPBWPList) {
                                String brandMappingKey = QMSPObj.QMSP_Quarter__c+'_'+QMSPObj.VME_Brand__r.Name;
                                
                                if(selectedFilterValues.get('Quarter') != 'Select_Quarter'){
                                        brandMappingKey = selectedFilterValues.get('Quarter')+'_'+QMSPObj.VME_Brand__r.Name;
                                }
                                //System.debug(QMSPObj);
                                //
                                if(!brandWiseObject.containsKey(brandMappingKey)){
                                        CampaignShadowObject campaignObj = new CampaignShadowObject();
                                        campaignObj.Brand = QMSPObj.VME_Brand__r.Name;
                                        campaignObj.Quarter = QMSPObj.QMSP_Quarter__c;
                                        campaignObj.VME_Approved_Budget = (Decimal) QMSPObj.get('VME_Approved_Budget');
                                        campaignObj.VME_Approved_Budget_c = QMSPObj.VME_Approved_Budget__c;
                                        campaignObj.VME_Approved_P_U_Amount =  (Decimal) QMSPObj.get('VME_Approved_P_U_Amount');
                                        campaignObj.VME_Approved_P_U_Amount_c = QMSPObj.VME_Approved_P_U_Amount__c;
                                        campaignObj.VME_Approved_Volume_c = QMSPObj.VME_Approved_Volume__c;
                                        campaignObj.VME_Planned_Budget =  (Decimal) QMSPObj.get('VME_Planned_Budget');
                                        campaignObj.VME_Planned_Budget_c = QMSPObj.VME_Planned_Budget__c;
                                        campaignObj.VME_Planned_P_U_Amount =  (Decimal) QMSPObj.get('VME_Planned_P_U_Amount');
                                        campaignObj.VME_Planned_P_U_Amount_c =  QMSPObj.VME_Planned_P_U_Amount__c;
                                        campaignObj.VME_Planned_Volume_c = QMSPObj.VME_Planned_Volume__c;
                                       campaignObj.VME_Adjust_Budget =  (Decimal) QMSPObj.get('VME_Adjust_Budget');
                                        campaignObj.VME_Adjust_Budget_c = QMSPObj.VME_Adjust_Budget__c;
                                        campaignObj.VME_Adjust_P_U_Amount =  (Decimal) QMSPObj.get('VME_Adjust_P_U_Amount');
                                        campaignObj.VME_Adjust_P_U_Amount_c = QMSPObj.VME_Adjust_P_U_Amount__c;
                                        campaignObj.VME_Adjust_volume_c = QMSPObj.VME_Adjust_volume__c;
                                        campaignObj.VME_Actual_Spent =  (Decimal) QMSPObj.get('VME_Actual_Spent');
                                        campaignObj.VME_Actual_Spent_c = QMSPObj.VME_Actual_Spent__c;
                                        campaignObj.VME_Actual_Volume_c = QMSPObj.VME_Actual_Volume__c;
                                        campaignObj.VME_Under_Over_Run =  (Decimal) QMSPObj.get('VME_Under_Over_Run');
                                        campaignObj.VME_Under_Over_Run_c = QMSPObj.VME_Under_Over_Run__c;
                                        brandWiseObject.put(brandMappingKey, campaignObj);
                                }else{

                                        CampaignShadowObject campaignObj = brandWiseObject.get(brandMappingKey);
                                       campaignObj.VME_Approved_Budget +=  (Decimal) QMSPObj.get('VME_Approved_Budget');
                                        campaignObj.VME_Approved_Budget_c += QMSPObj.VME_Approved_Budget__c;
                                        campaignObj.VME_Approved_P_U_Amount +=  (Decimal) QMSPObj.get('VME_Approved_P_U_Amount');
                                        campaignObj.VME_Approved_P_U_Amount_c += QMSPObj.VME_Approved_P_U_Amount__c;
                                        campaignObj.VME_Approved_Volume_c += QMSPObj.VME_Approved_Volume__c;
                                       campaignObj.VME_Planned_Budget +=  (Decimal) QMSPObj.get('VME_Planned_Budget');
                                        campaignObj.VME_Planned_Budget_c += QMSPObj.VME_Planned_Budget__c;
                                        campaignObj.VME_Planned_P_U_Amount +=  (Decimal) QMSPObj.get('VME_Planned_P_U_Amount');
                                        campaignObj.VME_Planned_P_U_Amount_c +=  QMSPObj.VME_Planned_P_U_Amount__c;
                                        campaignObj.VME_Planned_Volume_c += QMSPObj.VME_Planned_Volume__c;
                                       campaignObj.VME_Adjust_Budget +=  (Decimal) QMSPObj.get('VME_Adjust_Budget');
                                        campaignObj.VME_Adjust_Budget_c += QMSPObj.VME_Adjust_Budget__c;
                                       campaignObj.VME_Adjust_P_U_Amount +=  (Decimal) QMSPObj.get('VME_Adjust_P_U_Amount');
                                        campaignObj.VME_Adjust_P_U_Amount_c += QMSPObj.VME_Adjust_P_U_Amount__c;
                                        campaignObj.VME_Adjust_volume_c += QMSPObj.VME_Adjust_volume__c;
                                        campaignObj.VME_Actual_Spent +=  (Decimal) QMSPObj.get('VME_Actual_Spent');
                                        campaignObj.VME_Actual_Spent_c += QMSPObj.VME_Actual_Spent__c;
                                        campaignObj.VME_Actual_Volume_c += QMSPObj.VME_Actual_Volume__c;
                                       campaignObj.VME_Under_Over_Run +=  (Decimal) QMSPObj.get('VME_Under_Over_Run');
                                        campaignObj.VME_Under_Over_Run_c += QMSPObj.VME_Under_Over_Run__c;

                                        brandWiseObject.put(brandMappingKey, campaignObj);

                                }

                                
                        }

                        //System.debug('brandWiseObject :: '+ brandWiseObject);
                        //finalizing Master Wrapper for UI
                        masterWrapper.QMSP_Wrapper_List=QMSP_Wrapper_List;
                        masterWrapper.BrandWisePlanner_Wrapper_List = brandWiseObject;
                }

                catch(Exception e) {
                        System.debug('Planner Exception Occured in :' + e.getLineNumber());
                        System.debug(e.getMessage() + ' >> '+ e.getCause());
                        masterWrapper.QMSP_Wrapper_List=new List<QMSP_Wrapper>();
                        masterWrapper.BrandWisePlanner_Wrapper_List = new Map<String, CampaignShadowObject>();
                        masterWrapper.statusOfTransaction='ERROR';
                        masterWrapper.errorMsgOfTransaction='Error is '+e.getMessage()+' occurs in line '+e.getLineNumber();
                }

                return masterWrapper;
        }

        @AuraEnabled public static List<VME_Schemes__c> getMyRetailerScheme(String baseSchemeId) {
                return [SELECT Id, VME_Retailer__c, VME_Retailer__r.Id, VME_Retailer__r.Name, VME_Retailer__r.Dealer_CI_Code__c FROM VME_Schemes__c WHERE RecordTypeId =: CHILD_SCHEME_RECORD_TYPE AND VME_Parent_Scheme__c =: baseSchemeId ];
        }

        @AuraEnabled public static List<VME_Bundling__c> getMyBundlingScheme(String baseSchemeId) {
                return [SELECT Id, Name, VME_Model_Derivative__c, VME_Model_Derivative__r.Id, VME_Model_Derivative__r.Name, VME_Model_Derivative__r.ProductCode, VME_Model_Derivative__r.Model__c, VME_Model_Derivative__r.Model__r.Name, VME_Model_Derivative__r.Model__r.ProductCode, VME_Scheme__c, Asset__c, Asset__r.Name, Asset__r.Short_VIN__c, Asset__r.Model__r.Name, Asset__r.Model__c, Asset__r.Derivative__r.Name, Asset__r.Derivative__c FROM VME_Bundling__c WHERE VME_Scheme__c =: baseSchemeId ];
        }

        //Master Wrapper sending to VME Planner
        public class VME_Planner_Wrapper {
                @AuraEnabled public List<QMSP_Wrapper> QMSP_Wrapper_List {get;set;}
                @AuraEnabled public Map<String, CampaignShadowObject> BrandWisePlanner_Wrapper_List {get;set;}
                @AuraEnabled public String statusOfTransaction {get;set;}
                @AuraEnabled public String errorMsgOfTransaction {get;set;}
        }

        //First level Wrapper 
        public class QMSP_Wrapper {
                @AuraEnabled public Campaign QMSP_Object {get;set;}
                @AuraEnabled public String underOverRunNotification {get;set;}
                @AuraEnabled public Decimal Total_Approved_Amount {get;set;}
                @AuraEnabled public List<VME_Wrapper>VME_Wrapper_List {get;set;}

                public QMSP_Wrapper(Campaign QMSP_Object, List<VME_Wrapper> VME_Wrapper_List, Decimal Total_Approved_Amount, String underOverRunNotification) {
                        this.QMSP_Object=QMSP_Object;
                        this.VME_Wrapper_List=VME_Wrapper_List;
                        this.Total_Approved_Amount=Total_Approved_Amount;
                        this.underOverRunNotification=underOverRunNotification;
                }
        }

        //Second level Wrapper 
        public class VME_Wrapper {
                @AuraEnabled public VME_Campaign__c VME_Object {get;set;}
                @AuraEnabled public List<VME_Schemes__c>Scheme_List {get;set;}

                public VME_Wrapper(VME_Campaign__c VME_Object, List<VME_Schemes__c> Scheme_List) {
                        this.VME_Object=VME_Object;
                        this.Scheme_List=Scheme_List;
                }
        }

        //brand wise quater planner wrapper 
        public class BrandWiseQuarterPlanWrapper {

                @AuraEnabled public String parameterName;
                @AuraEnabled public Decimal approvedValue;
                @AuraEnabled public Decimal plannedValue;
                @AuraEnabled public Decimal adjustedValue;
                @AuraEnabled public Decimal actualvalue;
                
                BrandWiseQuarterPlanWrapper(){
                        this.parameterName = '';
                        this.approvedValue = 0.0;
                        this.plannedValue = 0.0;
                        this.adjustedValue = 0.0;
                        this.actualvalue = 0.0;
                }
        }

        public class CampaignShadowObject {
                @AuraEnabled public String Brand;
                @AuraEnabled public String Quarter;
                @AuraEnabled public Decimal VME_Approved_Budget;
                @AuraEnabled public Decimal VME_Approved_Budget_c;
                @AuraEnabled public Decimal VME_Approved_P_U_Amount;
                @AuraEnabled public Decimal VME_Approved_P_U_Amount_c;
                @AuraEnabled public Decimal VME_Approved_Volume_c;
                @AuraEnabled public Decimal VME_Planned_Budget;
                @AuraEnabled public Decimal VME_Planned_Budget_c;
                @AuraEnabled public Decimal VME_Planned_P_U_Amount;
                @AuraEnabled public Decimal VME_Planned_P_U_Amount_c;
                @AuraEnabled public Decimal VME_Planned_Volume_c;
                @AuraEnabled public Decimal VME_Adjust_Budget;
                @AuraEnabled public Decimal VME_Adjust_Budget_c;
                @AuraEnabled public Decimal VME_Adjust_P_U_Amount;
                @AuraEnabled public Decimal VME_Adjust_P_U_Amount_c;
                @AuraEnabled public Decimal VME_Adjust_volume_c;
                @AuraEnabled public Decimal VME_Actual_Spent;
                @AuraEnabled public Decimal VME_Actual_Spent_c;
                @AuraEnabled public Decimal VME_Actual_Volume_c;
                @AuraEnabled public Decimal VME_Under_Over_Run;
                @AuraEnabled public Decimal VME_Under_Over_Run_c;

                CampaignShadowObject(){

                        this.VME_Approved_Budget = 0.0;
                        this.VME_Approved_Budget_c = 0.0;
                        this.VME_Approved_P_U_Amount = 0.0;
                        this.VME_Approved_P_U_Amount_c = 0.0;
                        this.VME_Approved_Volume_c = 0.0;
                        this.VME_Planned_Budget = 0.0;
                        this.VME_Planned_Budget_c = 0.0;
                        this.VME_Planned_P_U_Amount = 0.0;
                        this.VME_Planned_P_U_Amount_c = 0.0;
                        this.VME_Planned_Volume_c = 0.0;
                        this.VME_Adjust_Budget = 0.0;
                        this.VME_Adjust_Budget_c = 0.0;
                        this.VME_Adjust_P_U_Amount = 0.0;
                        this.VME_Adjust_P_U_Amount_c = 0.0;
                        this.VME_Adjust_volume_c = 0.0;
                        this.VME_Actual_Spent = 0.0;
                        this.VME_Actual_Spent_c = 0.0;
                        this.VME_Actual_Volume_c = 0.0;
                        this.VME_Under_Over_Run = 0.0;
                        this.VME_Under_Over_Run_c = 0.0;

                }
        }
}