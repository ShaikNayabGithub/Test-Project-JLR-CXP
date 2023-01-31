/*--
||  Name : VME_Utility_Class.apxc
||  Author : Tamanna Shukla
||  Purpose: This is the reusable class for the VME Module.
||  Created Date : 15/04/2019
||  Modified By: Sumit Kumar
||  Modified Date : 21/04/2019
||  Reason : Adding new generic funtion to it.
--*/
public class VME_Utility_Class {
        //  getLocaleToDateTimeFmtMap  : Returns a map of user locale | datetime format for that locale
        private static Map < String, String > localeToDateTimeFmtMap = new Map < String, String > {
                'ar' => 'dd/MM/yyyy',
                'ar_AE' => 'dd/MM/yyyy',
                'ar_BH' => 'dd/MM/yyyy',
                'ar_JO' => 'dd/MM/yyyy',
                'ar_KW' => 'dd/MM/yyyy',
                'ar_LB' => 'dd/MM/yyyy',
                'ar_SA' => 'dd/MM/yyyy',
                'bg_BG' => 'yyyy-M-d',
                'ca' => 'dd/MM/yyyy',
                'ca_ES' => 'dd/MM/yyyy',
                'ca_ES_EURO' => 'dd/MM/yyyy',
                'cs' => 'd.M.yyyy',
                'cs_CZ' => 'd.M.yyyy',
                'da' => 'dd-MM-yyyy',
                'da_DK' => 'dd-MM-yyyy',
                'de' => 'dd.MM.yyyy',
                'de_AT' => 'dd.MM.yyyy',
                'de_AT_EURO' => 'dd.MM.yyyy',
                'de_CH' => 'dd.MM.yyyy',
                'de_DE' => 'dd.MM.yyyy',
                'de_DE_EURO' => 'dd.MM.yyyy',
                'de_LU' => 'dd.MM.yyyy',
                'de_LU_EURO' => 'dd.MM.yyyy',
                'el_GR' => 'd/M/yyyy',
                'en_AU' => 'd/MM/yyyy',
                'en_B' => 'M/d/yyyy',
                'en_BM' => 'M/d/yyyy',
                'en_CA' => 'dd/MM/yyyy',
                'en_GB' => 'dd/MM/yyyy',
                'en_GH' => 'M/d/yyyy',
                'en_ID' => 'M/d/yyyy',
                'en_IE' => 'dd/MM/yyyy',
                'en_IN' => 'dd/MM/yyyy',
                'en_IE_EURO' => 'dd/MM/yyyy',
                'en_NZ' => 'd/MM/yyyy',
                'en_SG' => 'M/d/yyyy',
                'en_US' => 'M/d/yyyy',
                'en_ZA' => 'yyyy/MM/dd',
                'es' => 'd/MM/yyyy',
                'es_AR' => 'dd/MM/yyyy',
                'es_BO' => 'dd-MM-yyyy',
                'es_CL' => 'dd-MM-yyyy',
                'es_CO' => 'd/MM/yyyy',
                'es_CR' => 'dd/MM/yyyy',
                'es_EC' => 'dd/MM/yyyy',
                'es_ES' => 'd/MM/yyyy',
                'es_ES_EURO' => 'd/MM/yyyy',
                'es_GT' => 'd/MM/yyyy',
                'es_HN' => 'MM-dd-yyyy',
                'es_MX' => 'd/MM/yyyy',
                'es_PE' => 'dd/MM/yyyy',
                'es_PR' => 'MM-dd-yyyy',
                'es_PY' => 'dd/MM/yyyy',
                'es_SV' => 'MM-dd-yyyy',
                'es_UY' => 'dd/MM/yyyy',
                'es_VE' => 'dd/MM/yyyy',
                'et_EE' => 'd.MM.yyyy',
                'fi' => 'd.M.yyyy',
                'fi_FI' => 'd.M.yyyy',
                'fi_FI_EURO' => 'd.M.yyyy',
                'fr' => 'dd/MM/yyyy',
                'fr_BE' => 'd/MM/yyyy',
                'fr_CA' => 'yyyy-MM-dd',
                'fr_CH' => 'dd.MM.yyyy',
                'fr_FR' => 'dd/MM/yyyy',
                'fr_FR_EURO' => 'dd/MM/yyyy',
                'fr_LU' => 'dd/MM/yyyy',
                'fr_MC' => 'dd/MM/yyyy',
                'hr_HR' => 'yyyy.MM.dd',
                'hu' => 'yyyy.MM.dd.',
                'hy_AM' => 'M/d/yyyy',
                'is_IS' => 'd.M.yyyy',
                'it' => 'dd/MM/yyyy',
                'it_CH' => 'dd.MM.yyyy',
                'it_IT' => 'dd/MM/yyyy',
                'iw' => 'dd/MM/yyyy',
                'iw_IL' => 'dd/MM/yyyy',
                'ja' => 'yyyy/MM/dd',
                'ja_JP' => 'yyyy/MM/dd',
                'kk_KZ' => 'M/d/yyyy',
                'km_KH' => 'M/d/yyyy',
                'ko' => 'yyyy. M. d',
                'ko_KR' => 'yyyy. M. d',
                'lt_LT' => 'yyyy.M.d',
                'lv_LV' => 'yyyy.d.M',
                'ms_MY' => 'dd/MM/yyyy',
                'nl' => 'd-M-yyyy',
                'nl_BE' => 'd/MM/yyyy',
                'nl_NL' => 'd-M-yyyy',
                'nl_SR' => 'd-M-yyyy',
                'no' => 'dd.MM.yyyy',
                'no_NO' => 'dd.MM.yyyy',
                'pl' => 'yyyy-MM-dd',
                'pt' => 'dd-MM-yyyy',
                'pt_AO' => 'dd-MM-yyyy',
                'pt_BR' => 'dd/MM/yyyy',
                'pt_PT' => 'dd-MM-yyyy',
                'ro_RO' => 'dd.MM.yyyy',
                'ru' => 'dd.MM.yyyy',
                'sk_SK' => 'd.M.yyyy',
                'sl_SI' => 'd.M.y',
                'sv' => 'yyyy-MM-dd',
                'sv_SE' => 'yyyy-MM-dd',
                'th' => 'M/d/yyyy',
                'th_TH' => 'd/M/yyyy',
                'tr' => 'dd.MM.yyyy',
                'ur_PK' => 'M/d/yyyy',
                'vi_VN' => 'dd/MM/yyyy',
                'zh' => 'yyyy-M-d',
                'zh_CN' => 'yyyy-M-d',
                'zh_HK' => 'yyyy-M-d',
                'zh_TW' => 'yyyy/M/d'
        };
        //getting category - subcategory Name - c ode in Map
        public static Map < String, String > getCatSubCatCodeMapping() {
                //Getting VME Channel Matrix Dependency for Matrix Selection
                List < VME_CXP_Channel_Matrix__mdt > VME_ChannelMatrix_Map = [Select id, Approved__c, Category__c, C_Code__c, Demo_Courtesy__c, Discretionary__c, Export__c, Fleet_Business__c, MDR_Rental__c, OUV__c, Private__c, Regular__c, SC_Code__c, Self_Regs__c, Stock__c, Sub_Category__c, Tactical__c, Label from VME_CXP_Channel_Matrix__mdt];
                Map < String, String > catSubCatMap = new Map < String, String > ();
                for (VME_CXP_Channel_Matrix__mdt sObj: VME_ChannelMatrix_Map) {
                        catSubCatMap.put(sObj.Category__c + '-C', sObj.C_Code__c);
                        catSubCatMap.put(sObj.Sub_Category__c + '-SC', sObj.SC_Code__c);
                }
                return catSubCatMap;
        }

           public static Map < String, String > getCatSubCatCodeMappingForL2() {
                //Getting VME Channel Matrix Dependency for Matrix Selection
                List < VME_CXP_SubCategories_L2__mdt > VME_subCat_Map = [Select id,Label,Parent_Category__c,Subcategory_Name__c from VME_CXP_SubCategories_L2__mdt];
                List < VME_CXP_Categories_L1__mdt > VME_Cat_Map = [Select id,Label,Category_Name__c from VME_CXP_Categories_L1__mdt];
             
                Map < String, String > catSubCatMap = new Map < String, String > ();
                for (VME_CXP_SubCategories_L2__mdt sObj: VME_subCat_Map) {
                        catSubCatMap.put(sObj.Subcategory_Name__c + '-SC', sObj.Label);
                }
                for (VME_CXP_Categories_L1__mdt sObj: VME_Cat_Map) {
                        catSubCatMap.put(sObj.Category_Name__c + '-C', sObj.Label);
                }
                return catSubCatMap;
        }
        //getting all channel matrix first level dependency
        public static Map < String, Set < String >> getVMEChannelMatrixDependency() {
                //Getting VME Channel Matrix Dependency for Matrix Selection
                List < VME_CXP_Channel_Matrix_Dependency__mdt > VME_ChannelMatrix_DependencyMap = [Select id, Brand_Order_Type_Code__c, Details__c, Mapping__c, Type_of_Sale_Code_L2__c, Unique_ID__c from VME_CXP_Channel_Matrix_Dependency__mdt];
                Map < String, Set < String >> vmeChannelMatrixDependencyMap = new Map < String, Set < String >> ();
                for (VME_CXP_Channel_Matrix_Dependency__mdt sObj: VME_ChannelMatrix_DependencyMap) {
                        if (!vmeChannelMatrixDependencyMap.containsKey(sObj.Brand_Order_Type_Code__c + '_' + sObj.Type_of_Sale_Code_L2__c)) {
                                vmeChannelMatrixDependencyMap.put(sObj.Brand_Order_Type_Code__c + '_' + sObj.Type_of_Sale_Code_L2__c, new Set < String > {
                                        sObj.Mapping__c
                                });
                        } else {
                                Set < String > tempSet = vmeChannelMatrixDependencyMap.get(sObj.Brand_Order_Type_Code__c + '_' + sObj.Type_of_Sale_Code_L2__c);
                                tempSet.add(sObj.Mapping__c);
                                vmeChannelMatrixDependencyMap.put(sObj.Brand_Order_Type_Code__c + '_' + sObj.Type_of_Sale_Code_L2__c, tempSet);
                        }
                }
                return vmeChannelMatrixDependencyMap;
        }
        //getting the Current User Details
        public static user fetchUser() {
                // query current user information [SELECT Id,Name,TimeZoneSidKey,Username,Market__c,Country,Email,FirstName,LastName,IsActive,User_Status__c, Sales_Region__c,LocaleSidKey,LanguageLocaleKey, CurrencyIsoCode, DefaultCurrencyIsoCode, Country_ISO_Code__c FROM User WHERE Id =: UserInfo.getUserId() limit 1];
                User loggedUser = [SELECT Id, Name, Username, Market__c, FirstName, LastName, User_Status__c, Sales_Region__c, Country_ISO_Code__c FROM User WHERE Id = : UserInfo.getUserId() limit 1];
                //putting used based local locale value and date format
                loggedUser.CPF__c = getUserDateTimeFormat();
                return loggedUser;
        }
        //  getUserDateTimeFormat: e.g. M/d/yyyy hh.mm.ss
        public static String getUserDateTimeFormat() {
                String userLocale = UserInfo.getLocale();
                if (!localeToDateTimeFmtMap.containsKey(userLocale)) return 'yyyy-mm-dd hh.mm.ss';
                return localeToDateTimeFmtMap.get(userLocale);
        }
        //Getting Dependent Picklist Based on Object and Field API Name
        public static Map < String, List < String >> getDependentPicklist(sObject objDetail, string contrfieldApiName, string depfieldApiName) {
                String controllingField = contrfieldApiName.toLowerCase();
                String dependentField = depfieldApiName.toLowerCase();
                Map < String, List < String >> objResults = new Map < String, List < String >> ();
                Schema.sObjectType objType = objDetail.getSObjectType();
                if (objType == null) {
                        return objResults;
                }
                Map < String, Schema.SObjectField > objFieldMap = objType.getDescribe().fields.getMap();
                if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
                        return objResults;
                }
                Schema.SObjectField theField = objFieldMap.get(dependentField);
                Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
                List < Schema.PicklistEntry > contrEntries = ctrlField.getDescribe().getPicklistValues();
                List < PicklistEntryWrapper > depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
                List < String > controllingValues = new List < String > ();
                for (Schema.PicklistEntry ple: contrEntries) {
                        String label = ple.getLabel();
                        objResults.put(label, new List < String > ());
                        controllingValues.add(label);
                }
                for (PicklistEntryWrapper plew: depEntries) {
                        String label = plew.label;
                        String validForBits = base64ToBits(plew.validFor);
                        for (Integer i = 0; i < validForBits.length(); i++) {
                                String bit = validForBits.mid(i, 1);
                                if (bit == '1') {
                                        objResults.get(controllingValues.get(i)).add(label);
                                }
                        }
                }
                return objResults;
        }
        public static String decimalToBinary(Integer val) {
                String bits = '';
                while (val > 0) {
                        Integer remainder = Math.mod(val, 2);
                        val = Integer.valueOf(Math.floor(val / 2));
                        bits = String.valueOf(remainder) + bits;
                }
                return bits;
        }
        public static String base64ToBits(String validFor) {
                if (String.isEmpty(validFor)) return '';
                String validForBits = '';
                for (Integer i = 0; i < validFor.length(); i++) {
                        String thisChar = validFor.mid(i, 1);
                        Integer val = base64Chars.indexOf(thisChar);
                        String bits = decimalToBinary(val).leftPad(6, '0');
                        validForBits += bits;
                }
                return validForBits;
        }
        private static final String base64Chars = '' + 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + 'abcdefghijklmnopqrstuvwxyz' + '0123456789+/';
        private static List < PicklistEntryWrapper > wrapPicklistEntries(List < Schema.PicklistEntry > PLEs) {
                return (List < PicklistEntryWrapper > )
                JSON.deserialize(JSON.serialize(PLEs), List < PicklistEntryWrapper > .class);
        }
        public class PicklistEntryWrapper {
                public String active {
                        get;
                        set;
                }
                public String defaultValue {
                        get;
                        set;
                }
                public String label {
                        get;
                        set;
                }
                public String value {
                        get;
                        set;
                }
                public String validFor {
                        get;
                        set;
                }
                public PicklistEntryWrapper() {}
        }
        //Basically it lazily reads in configured currencies and allows you to convert between any currency, 
        //from a supplied currency to the corporate currency or from a supplied currency to the users own currency.
        public static Decimal convertCurrencyGBP_to_Other(Decimal amountToConvert, String fromISOCode, String toISOCode) {
                if (String.isEmpty(fromISOCode) || String.isEmpty(toISOCode)) {
                        return amountToConvert;
                }
                Map < String, CurrencyType > conversions = new Map < String, CurrencyType > ();
                for (CurrencyType cur: [select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive = true]) {
                        conversions.put(cur.IsoCode, cur);
                }
                // ensure valid to/from ISO
                if (!conversions.containsKey(fromISOCode)) {
                        return amountToConvert;
                }
                if (!conversions.containsKey(toISOCode)) {
                        return amountToConvert;
                }
                // if same currencies we simply round
                if (fromISOCode.equalsIgnoreCase(toISOCode)) {
                        return amountToConvert.setScale(conversions.get(fromISOCode.toUpperCase()).DecimalPlaces, System.RoundingMode.HALF_UP);
                }
                // get values and then rate
                final CurrencyType fromCur = conversions.get(fromISOCode.toUpperCase());
                final Decimal fromRate = fromCur.ConversionRate;
                final CurrencyType toCur = conversions.get(toISOCode.toUpperCase());
                final Decimal toRate = toCur.ConversionRate;
                final Decimal rate = toRate / fromRate;
                // calc
                final Decimal result = amountToConvert * rate;
                final Decimal resultRounded = result.setScale(toCur.DecimalPlaces, System.RoundingMode.HALF_UP);
                // return
                return resultRounded;
        }
        //This is the Method to get theBrand / market Custom Settings Values Based on Product Code
        // Added by Sumit Kumar on 5th June 2019
        public static Map < String, List < String >> getVMEBrandModelRealData() {
                Map < String, List < String >> brandModelDetailsMap = new Map < String, List < String >> ();
                List < Product2 > allModelList = [SELECT Id, Name, ProductCode, Make__c, Make__r.Name FROM Product2 WHERE Make__c != null AND Make__r.Name != null AND Model__c = null AND RecordType.Name = 'Model'
                        LIMIT 49999
                ];
                for (Product2 model: allModelList) {
                        if (brandModelDetailsMap.containsKey(model.Make__r.Name)) {
                                String Model_ProductCode = model.Name + ' (' + model.ProductCode + ')';
                                if (model.ProductCode == null || model.ProductCode == '') {
                                        Model_ProductCode = model.Name;
                                }
                                List < String > tempList = new List < String > ();
                                tempList = brandModelDetailsMap.get(model.Make__r.Name);
                                tempList.add(Model_ProductCode);
                                tempList.sort();
                                brandModelDetailsMap.put(model.Make__r.Name, tempList);
                        } else {
                                String Model_ProductCode = model.Name + ' (' + model.ProductCode + ')';
                                if (model.ProductCode == null || model.ProductCode == '') {
                                        Model_ProductCode = model.Name;
                                }
                                brandModelDetailsMap.put(model.Make__r.Name, new List < String > {
                                        Model_ProductCode
                                });
                        }
                }
                return brandModelDetailsMap;
        }
        //This is the Method to form the picklist value/Label in form of Map<String,String>
        public static Map < String, String > getAllPickListValue(String ObjectApiName, String FieldApiName) {
                Map < String, String > pickListValuesMap = new Map < String, String > ();
                Schema.DescribeFieldResult fieldResult = schema.getGlobalDescribe().get(ObjectApiName).getDescribe().fields.getMap().get(FieldApiName).getDescribe();
                List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
                for (Schema.PicklistEntry pickListVal: ple) {
                        pickListValuesMap.put(pickListVal.getLabel(), pickListVal.getValue());
                }
                return pickListValuesMap;
        }
        //Helper Code for VME_BatchClassWBSMappingTransformation
        //Start
        public Map < String, Schema.SObjectField > getFieldMap(String objectName) {
                system.debug('***What Came Here***' + objectName);
                Map < String, Schema.SObjectType > globldes; //Map - Name to Schema of SObjects.
                try {
                        globldes = Schema.getGlobalDescribe(); //Fills the map of Object Name to Schema of each Object.
                } catch (Exception e) {}
                Map < String, Schema.SObjectField > fieldMap = globldes.get(objectName).getDescribe().fields.getMap();
                return fieldMap;
        }
        public String createQuery(String objectName, Map < String, Schema.SObjectField > fieldMap) {
                String RecordQuery = 'select ';
                for (String nm: fieldMap.keyset()) {
                        if (RecordQuery == 'select ') {
                                RecordQuery = RecordQuery + nm;
                        } else {
                                RecordQuery = RecordQuery + ', ' + nm;
                        }
                }
                RecordQuery = RecordQuery + ' from ' + objectName;
                return RecordQuery;
        }
        public Set < String > getPicklistValues(String objectName, String fieldName) {
                Map < String, Schema.SObjectField > actStgObjfieldMap = getFieldMap(objectName);
                Schema.DescribeFieldResult F = actStgObjfieldMap.get(fieldName).getDescribe();
                String type1 = String.valueOf(F.getType());
                Set < String > picklistVal = new Set < String > ();
                if (type1 == 'PICKLIST') {
                        List < Schema.PicklistEntry > P = F.getPicklistValues();
                        for (Schema.PicklistEntry ins: P) {
                                picklistVal.add(ins.getLabel().toLowerCase().trim());
                        }
                        System.debug(picklistVal);
                }
                return picklistVal;
        }
        /*****************************************
        Purpose     : Method for getting Record Type Id                                  
        Return Type : Record Id
        *****************************************/
        @AuraEnabled
        public static String getDynamicRecordTypeId(String objectType, String recordTypeName) {
                return getRecordTypeId(objectType, recordTypeName);
        }
        public static Id getRecordTypeId(String objectType, String recordTypeName) {
                Id recTypeId = Schema.getGlobalDescribe().get(objectType).getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
                return recTypeId;
        }
        public static String getDynamQuery(String objectAPIName, String criteria) {
                Map < String, Schema.SObjectField > StagingCustomerFieldMap;
                sObjectType ObjectSchema = schema.getGlobalDescribe().get(objectAPIName);
                StagingCustomerFieldMap = objectSchema.getDescribe().fields.getMap();
                //Construct generic query string used to query 'objectAPIName' data dynamically
                String query = 'Select ';
                for (Schema.SObjectField s: StagingCustomerFieldMap.values()) {
                        query = query + s.getDescribe().getName() + ',';
                }
                query = query.removeEnd(',');
                query = query + ' from ' + objectAPIName + ' where ' + criteria;
                return query;
        }
        public static Map < String, String > getMarketCode() {
                List < VME_CXP_Market_Codes__mdt > VME_MarketCodeMap = [Select id, Label, Market__c from VME_CXP_Market_Codes__mdt];
                Map < String, String > marketCode = new Map < String, String > ();
                for (VME_CXP_Market_Codes__mdt sObj: VME_MarketCodeMap) {
                        marketCode.put(sObj.Market__c, sObj.Label);
                }
                return marketCode;
        }
        public static Map < String, String > getBrandCode() {
                List < VME_CXP_Brand_Code__mdt > brandCodeMap = [Select Label, Brand_Name__c from VME_CXP_Brand_Code__mdt];
                Map < String, String > brandCodeValuesMap = new Map < String, String > ();
                for (VME_CXP_Brand_Code__mdt sObj: brandCodeMap) {
                        brandCodeValuesMap.put(sObj.Brand_Name__c, sObj.Label);
                }
                return brandCodeValuesMap;
        }
        public static Map < String, VME_CXP_Quarter_Info__mdt > getQuarterInfos() {
                List < VME_CXP_Quarter_Info__mdt > quarterCodeMap = [Select id, Label, End_Day__c, End_Month__c, Quarter_Code__c, Start_Day__c, Start_Month__c from VME_CXP_Quarter_Info__mdt];
                Map < String, VME_CXP_Quarter_Info__mdt > quarterCodeValuesMap = new Map < String, VME_CXP_Quarter_Info__mdt > ();
                for (VME_CXP_Quarter_Info__mdt sObj: quarterCodeMap) {
                        quarterCodeValuesMap.put(sObj.Quarter_Code__c, sObj);
                }
                return quarterCodeValuesMap;
        }
        public static Map < String, String > getCountryISOInfos() {
                List < VME_CXP_Country_ISO_Codes__mdt > countryCodeMap = [Select id, Label, Country_Name__c from VME_CXP_Country_ISO_Codes__mdt];
                Map < String, String > countryISOMap = new Map < String, String > ();
                for (VME_CXP_Country_ISO_Codes__mdt sObj: countryCodeMap) {
                        countryISOMap.put(sObj.Label, sObj.Country_Name__c);
                }
                return countryISOMap;
        }
        public static VME_Category_Adjustment_Ctrl.VMECampaignWrapper getUpdatedWrapperofCurrentVME(String recordId) {
                VME_Category_Adjustment_Ctrl.VMECampaignWrapper vmeCampaignWrapObj = new VME_Category_Adjustment_Ctrl.VMECampaignWrapper();
                vmeCampaignWrapObj.vmeCampaignWrap = [Select Id, Name, CurrencyIsoCode, QMSP_Campaign__c, VME_Category__c, VME_End_Date__c, VME_Sub_Category__c, VME_Start_Date__c, VME_External_ID__c, convertCurrency(VME_Actual_Amount__c), convertCurrency(VME_Adjusted_Budget__c), convertCurrency(VME_Adjusted_PU_Amount__c), VME_Adjusted_Volume__c, convertCurrency(VME_Approved_Budget__c), convertCurrency(VME_Approved_PU_Amount__c), VME_Approved_Volume__c, convertCurrency(VME_Planned_Budget__c), convertCurrency(VME_Planned_PU_Amount__c), VME_Planned_Volume__c, convertCurrency(VME_Total_Amount_Approved__c), VME_Model__c, VME_Model__r.Name, VME_Country_ISO_Code__c, VME_Brand__c,RecordType.Name
                        from VME_Campaign__c
                        where Id = : recordId limit 1
                ];
                vmeCampaignWrapObj.campEditable = true;
                vmeCampaignWrapObj.schemeList = getSchemeListBasedOnVMECampaign(recordId);
                return vmeCampaignWrapObj;
        }
        public static List < VME_Schemes__c > getSchemeListBasedOnVMECampaign(String vmeCampaignId) {
                Id parentRecordTypeId = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Parent');
                Id childRecordTypeId = VME_Utility_Class.getRecordTypeId('VME_Schemes__c', 'Child');
                return [SELECT Name, CurrencyIsoCode, Id, VME_Start_Date__c, VME_End_Date__c, VME_Trade_In__c,VME_Campaign__c, VME_JLR_Share__c, convertCurrency(VME_PU_Amount__c), VME_Retailer__c, VME_Consumed_Volume__c, VME_Claims_Approved__c, convertCurrency(VME_Total_Amount_Approved__c), convertCurrency(VME_Total_Amount_Available__c), VME_InActive__c, VME_Revise_Check__c, VME_Scheme_Type__c, VME_Level_3_Description__c, VME_Volume__c, convertCurrency(VME_Total_VME__c), VME_Color_Code_Exterior__c, VME_External_ID__c, VME_Manufacturing_End_Date__c, VME_Manufacturing_Start_Date__c, VME_Model_Year__c, convertCurrency(VME_Retailer_Contribution__c), VME_Market_Arrival_Start_Date__c, VME_Market_Arrival_End_Date__c, VME_Retailer__r.Name, RecordTypeId,
                        (SELECT Id, RecordTypeId FROM VME_Child_Schemes__r where VME_InActive__c = false AND recordTypeId = : childRecordTypeId),(SELECT Id FROM  VME_Bundlings__r)
                        from VME_Schemes__c
                        where VME_Campaign__c = : vmeCampaignId AND VME_InActive__c = false AND recordTypeId = : parentRecordTypeId ORDER BY VME_Scheme_Type__c DESC
                ];
        }
      
}