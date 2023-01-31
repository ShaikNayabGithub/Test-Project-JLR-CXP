/*
* S.No.     Name        Date(DD/MM/YYYY)    Change 
* 1.0       Ashwin      26/07/2021          CXPD-1360: Vehicle Selection VIN Search
* 
*/
public with sharing class AssetProductSearchController {
    /* public static User loggedInUser = [SELECT Id, AccountId, Contact.AccountId, ContactId, CurrencyIsoCode, Country, Market__c, Country_ISO_Code__c   
FROM User 
WHERE Id = :userinfo.getUserId() 
AND ContactId != null];  */
    
    public static User loggedInUser = getUserInformation(UserInfo.getUserId());
    public static Id assetVehcileRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId();
    public static Id assetVehcileOptionRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Vehicle_Option').getRecordTypeId();
    public static Id productVehcileRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Derivative').getRecordTypeId();
    
    public static User getUserInformation(Id userId) {
        if(loggedInUser == null || loggedInUser.Id != userId) {
            loggedInUser = [SELECT Id, AccountId, Contact.AccountId, ContactId, CurrencyIsoCode, Country, Market__c, Country_ISO_Code__c   
                            FROM User 
                            WHERE Id = :userId 
                            AND ContactId != null
                            AND AccountId != null];
        }
        return loggedInUser;
    }
    
    public static PickList_Value_Settings__mdt picklistValueList = getPicklistValueSettings();
    public static PickList_Value_Settings__mdt getPicklistValueSettings() {
        if(picklistValueList == null) {
            picklistValueList = [SELECT Opportunity_PurchaseType_Values__c, Opportunity_Stage_Values__c, Asset_Status_List__c, Asset_Common_Sale_Type__c, Market__c FROM PickList_Value_Settings__mdt LIMIT 1];
        }
        return picklistValueList;
    }
    
    public static List < String > AssetStatusList = getAssetStatusValues();
    public static List < String > getAssetStatusValues() {
        List < String > strList = new List < String > ();
        if(picklistValueList != null && String.isNotBlank(picklistValueList.Asset_Status_List__c)) {
            strList = picklistValueList.Asset_Status_List__c.split(',');
        }
        return strList;
    }
    
    public static List < String > AssetCommonSaleTypeList = getAssetCommonSaleTypeValues();
    public static List < String > getAssetCommonSaleTypeValues() {
        List < String > strList = new List < String > ();
        if(picklistValueList != null && String.isNotBlank(picklistValueList.Asset_Common_Sale_Type__c)) {
            strList = picklistValueList.Asset_Common_Sale_Type__c.split(',');
        }
        return strList;
    }
    
    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId) {
        system.debug('opportunityId'+opportunityId);
        return [SELECT Id, Name, Pricebook2Id, Asset__c, Purchase_Type__c, Primary_Model_Interest__c, (SELECT Id, Asset__c, Product2Id FROM OpportunityLineItems WHERE Product2.RecordTypeId = :productVehcileRecordTypeId LIMIT 1) FROM Opportunity where Id =:opportunityId];        
    }
    
    @AuraEnabled
    public static Map<String, String> getFieldLabel(String objectName) {    
        system.debug('FIELD LABEL');    
        return SchemaUtility.getObjectLabelMap(objectName);  
    }
    
    @AuraEnabled
    public static OpportunityLineItem getAssetLinkedOpportunities(String assetId) {
        List < OpportunityLineItem > lineItems = [SELECT CreatedDate, CreatedBy.Name, OpportunityId, Opportunity.Name, Opportunity.CreatedDate, Opportunity.CreatedBy.Name FROM OpportunityLineItem WHERE Asset__c = :assetId];
        if(lineItems != null && !lineItems.isEmpty()) {
            return lineItems.get(0);
        }
        return null;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> searchProductList(Id oppId, String modelId) {        
        List<Map<String, String>> optionsList = new List<Map<String, String>>();
        boolean isUsed = false;
        String oppPricebookId = null;
        Opportunity opp = [SELECT Id, Pricebook2Id, Purchase_Type__c, CurrencyISOCode FROM Opportunity WHERE Id = :oppId];
        if(opp != null) {
            if(opp.Purchase_Type__c != null && opp.Purchase_Type__c == 'Used Vehicle') {
                isUsed = true;
            }
            oppPricebookId = opp.Pricebook2Id;
        }
        
        system.debug(opp);
        List<PricebookEntry> productList = new List<PricebookEntry>();
        if(modelId == null || modelId == '' || modelId == 'none') {
            productList = [SELECT Product2Id, Product2.Name, Product2.ProductCode, Product2.Model_Year__c, Product2.Specification_Pack_Alternative__c, Product2.Engine_Type__c, 
                           Product2.Transmission__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Engine_Capacity_Alternative__c, Product2.Wheel_Driven__c, Product2.Fuel_Type_Alternative__c, 
                           Product2.Body_Style__c, Product2.Power_Output_Alternative__c, Product2.Make__c, Product2.Product_Description__c
                           FROM PricebookEntry 
                           WHERE Pricebook2Id = :opp.Pricebook2Id
                           AND Product2.RecordType.DeveloperName = 'Derivative'
                           AND CurrencyIsoCode = :opp.CurrencyIsoCode 
                           AND Pricebook2.IsActive = true 
                           AND IsActive = true
                           ORDER BY Product2.Name];
        }
        else{
            String prodName = '';
            List<Vehicle_Specification__c> vsList = [SELECT Name FROM Vehicle_Specification__c WHERE Id = :modelId];
            if(vsList.size() > 0) {
                prodName = vsList[0].Name;
            }
            String soqlQuery = 'SELECT Product2Id, Product2.Name, Product2.ProductCode, Product2.Model_Year__c, Product2.Specification_Pack_Alternative__c, Product2.Engine_Type__c, ';
            soqlQuery += 'Product2.Transmission__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Engine_Capacity_Alternative__c, Product2.Wheel_Driven__c, Product2.Fuel_Type_Alternative__c, ';
            soqlQuery += 'Product2.Body_Style__c, Product2.Power_Output_Alternative__c, Product2.Make__c, Product2.Product_Description__c FROM PricebookEntry ';
            // soqlQuery += 'WHERE Pricebook2Id IN (SELECT Pricebook2Id FROM Opportunity WHERE Id = \'' + oppId + '\') ';
            soqlQuery += 'WHERE Pricebook2Id = \'' + oppPricebookId + '\' ';
            soqlQuery += 'AND Product2.RecordType.DeveloperName = \'Derivative\' ';
            soqlQuery += 'AND Product2.Model_Alternative__c = \'' + prodName + '\' ';
            soqlQuery += 'AND CurrencyIsoCode = \'' + opp.CurrencyIsoCode + '\' ';
            soqlQuery += 'AND Pricebook2.IsActive = true ';
            soqlQuery += 'AND IsActive = true ';
            soqlQuery += 'ORDER BY Product2.Name';
            System.debug('### soqlQuery ### ' + soqlQuery);
            productList = Database.query(soqlQuery);
        }
        Set<Id> prodIds = new Set<Id>();
        for(PricebookEntry pe : productList) {
            prodIds.add(pe.Product2Id);
        }
        Map<Id, List<Asset>> prodToAssetMap = getProductAssetMap(prodIds, isUsed);
        for(PricebookEntry pe : productList) {
            if (isUsed){
                if (prodToAssetMap.containsKey(pe.Product2Id)) {
                    if (prodToAssetMap.get(pe.Product2Id).size() > 0) {
                        Map<String, String> optionsMap = new Map<String, String>();
                        optionsMap.put('label', pe.Product2.Product_Description__c);
                        optionsMap.put('filter_label', pe.Product2.ProductCode + '_' + pe.Product2.Product_Description__c);
                        optionsMap.put('value', pe.Product2Id);
                        optionsMap.put('size',  prodToAssetMap.containsKey(pe.Product2Id) ? '[' + prodToAssetMap.get(pe.Product2Id).size() + ']' : '[0]');
                        optionsList.add(optionsMap);}
                }
            }    
            else {
                //CXPD-2078
                String modelyear;
                if(pe.Product2.Model_Year__c !=null) modelyear = pe.Product2.Model_Year__c;
                System.debug('Model Year : '+pe.Product2.Name +' '+pe.Product2.Model_Year__c);
                Integer year = System.today().year();
                String currentYear = String.valueOf(year);
                String previousYear = String.valueOf(year-1);
                String comingYear = String.valueOf(year+1);
                if(modelyear!=null && (modelyear==currentyear || modelyear==previousYear || modelyear==comingYear)){
                    Map<String, String> optionsMap = new Map<String, String>();
                    optionsMap.put('label', pe.Product2.Product_Description__c);
                    optionsMap.put('filter_label', pe.Product2.ProductCode + '_' + pe.Product2.Product_Description__c);
                    optionsMap.put('value', pe.Product2Id);
                    optionsMap.put('size',  prodToAssetMap.containsKey(pe.Product2Id) ? '[' + prodToAssetMap.get(pe.Product2Id).size() + ']' : '[0]');
                    optionsList.add(optionsMap);
                }
            }
        }   
        return optionsList;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> searchModelList() {
        List< Map<String, String>> optionsList= new List<Map<String, String>>();
        List<String> modelNamesList = getModelAlternativeValues();
        String maket = '%'+loggedInUser.Market__c+'%';
        for(Vehicle_Specification__c model: [SELECT Id, Name, Model_Code__c FROM Vehicle_Specification__c 
                                             WHERE Recordtype.DeveloperName = 'Model' 
                                             AND Name IN :modelNamesList 
                                             AND Is_Currently_Sold__c= true 
                                             AND (Make__r.Name = 'Jaguar' OR Make__r.Name = 'Land Rover') 
                                             AND ( Not Not_Sold_Market_List__c LIKE :maket) 
                                             ORDER BY Sequence_Order__c ASC NULLS LAST, Name ASC]) {
                                                 Map<String, String> optionsmap= new Map<String, String>();
                                                 String modelandcode;
                                                 if(model.Name == 'Range Rover Evoque'){
                                                     modelandcode = model.Name+' - '+model.Model_Code__c;
                                                 }else{
                                                     modelandcode = model.Name;
                                                 }
                                                 optionsmap.put('label', modelandcode);
                                                 optionsmap.put('value', model.Id);           
                                                 optionsList.add(optionsmap);
                                             } 
        return optionsList;        
    }
    
    @AuraEnabled
    public static List<String> getModelAlternativeValues() {
        List<String> optionsList= new List<String>();         
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType objectSchema = schemaMap.get('Product2');
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap(); 
        Schema.DescribeFieldResult fieldResult = fieldMap.get('Model_Alternative__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple) {           
            optionsList.add(pickListVal.getValue());
        } 
        System.debug(optionsList + 'OptionsList');
        return optionsList;        
    }
    
    @AuraEnabled
    public static List<Asset> getAssetList(String opportunityId, String modelId, String productId) {
        if(loggedInUser.Country_ISO_Code__c == 'KR') {
            return getAssetListKR(opportunityId, modelId, productId);
        }
        
        String brand = '';   
        String modalName = '';
        Map<Id, Asset> assetMap;
        Opportunity presentOppRecord = [SELECT Id, Name, Pricebook2Id, Purchase_Type__c, Asset__c, Primary_Model_Interest__c, Primary_Model_Interest__r.Name, Brand__c, CurrencyISOCode FROM Opportunity where Id =:opportunityId];
        if(productId != null && productId != '' && productId != 'none') {
            if(presentOppRecord.Purchase_Type__c == 'Used Vehicle') {
                assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                               Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                               Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                                               Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c
                                               FROM Asset 
                                               WHERE Product2Id = :productId 
                                               AND AccountId = :loggedInUser.AccountId 
                                               AND New_or_Used__c = 'Used' 
                                               AND Status = 'For Sale' 
                                              ]);
            }
            else {
                // Only Applicable for New Vehicle as per CXPD-1696 (Removed Status check for Non-MENA Market)
                if(loggedInUser.Market__c == 'MENA') {
                    assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                                   Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                                   Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                                                   Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c
                                                   FROM Asset 
                                                   WHERE Product2Id = :productId 
                                                   AND AccountId = :loggedInUser.AccountId  
                                                   AND (New_or_Used__c = null OR New_or_Used__c != 'Used') 
                                                   AND Status IN :AssetStatusList
                                                   AND Common_Sale_Type__c IN :AssetCommonSaleTypeList 
                                                  ]);
                } else {
                    assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                                   Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                                   Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                                                   Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c
                                                   FROM Asset 
                                                   WHERE Product2Id = :productId 
                                                   AND AccountId = :loggedInUser.AccountId  
                                                   AND (New_or_Used__c = null OR New_or_Used__c != 'Used') 
                                                  ]);
                }
            }
        }
        else {
            if(modelId != null && modelId != '' && modelId != 'none') {
                Vehicle_Specification__c primaryIntrestModel = [SELECT Id, Make__c, Name FROM Vehicle_Specification__c WHERE Id=:modelId];
                brand = primaryIntrestModel.make__c;
                modalName = primaryIntrestModel.Name;
            } else {
                brand = presentOppRecord.Brand__c;            
                modalName = presentOppRecord.Primary_Model_Interest__r.Name;
            }
            if(presentOppRecord.Purchase_Type__c == 'Used Vehicle') {
                assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                               Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                               Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                                               Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c
                                               FROM Asset 
                                               WHERE Brand__c = :brand 
                                               AND AccountId = :loggedInUser.AccountId
                                               AND New_or_Used__c = 'Used' 
                                               AND Status = 'For Sale' 
                                               AND Product2Id != null
                                               AND Product2.Model_Alternative__c = :modalName]);
            } else {
                // Only Applicable for New Vehicle as per CXPD-1696 (Removed Status check for Non-MENA Market)
                if(loggedInUser.Market__c == 'MENA') {
                    assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                                   Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                                   Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c, 
                                                   Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c
                                                   FROM Asset 
                                                   WHERE Brand__c = :brand 
                                                   AND AccountId = :loggedInUser.AccountId
                                                   AND (New_or_Used__c = null OR New_or_Used__c != 'Used') 
                                                   AND Status IN :AssetStatusList 
                                                   AND Common_Sale_Type__c IN :AssetCommonSaleTypeList 
                                                   AND Product2Id != null
                                                   AND Product2.Model_Alternative__c = :modalName]);
                } else {
                    assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                                   Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                                   Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c, 
                                                   Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c
                                                   FROM Asset 
                                                   WHERE Brand__c = :brand 
                                                   AND AccountId = :loggedInUser.AccountId
                                                   AND (New_or_Used__c = null OR New_or_Used__c != 'Used') 
                                                   AND Product2Id != null
                                                   AND Product2.Model_Alternative__c = :modalName]);
                }
            }
            for(OpportunityLineItem oppLItem: [SELECT Id, Asset__c, Product2Id FROM OpportunityLineItem WHERE Asset__c IN :assetMap.values()]) {
                if(assetMap.containsKey(oppLItem.Asset__c)) assetMap.remove(oppLItem.Asset__c);
            }
        }
        Map<Id, List<Asset>> assetProductMap = new Map<Id, list<Asset>>();
        for(Asset singleAsset : assetMap.values()) { 
            if(! assetProductMap.containsKey(singleAsset.Product2Id)) assetProductMap.put(singleAsset.Product2Id, new List<Asset>());
            assetProductMap.get(singleAsset.Product2Id).add(singleAsset);
        }
        List<Asset> availableAssetList = new List<Asset>();
        // availableAssetList.clear();
        for(PricebookEntry pbEntry: [SELECT Id, Product2Id 
                                     FROM PricebookEntry 
                                     WHERE Pricebook2Id =:presentOppRecord.Pricebook2Id 
                                     AND Product2Id IN :assetProductMap.keyset()
                                     AND CurrencyIsoCode = :presentOppRecord.CurrencyIsoCode 
                                     AND Pricebook2.IsActive = true 
                                     AND IsActive = true]) {
                                         
                                         if(assetProductMap.containsKey(pbEntry.Product2Id)) {
                                             List<Asset> assetsToAdd = assetProductMap.get(pbEntry.Product2Id);
                                             Schema.SObjectType assetType = Schema.getGlobalDescribe().get('Asset');
                                             Schema.DescribeSObjectResult assetResult = assetType.getDescribe();
                                             Schema.DescribeFieldResult engineField = assetResult.fields.getMap().get('Engine__c').getDescribe();
                                             for(Asset ass : assetProductMap.get(pbEntry.Product2Id)) {
                                                 for(Schema.PicklistEntry plValue : engineField.getPicklistValues()) {
                                                     System.debug('plValue: ' + plValue + ' - Engine: ' + ass.Product2.Engine__c);
                                                     if(plValue.getValue() == ass.Product2.Engine__c) {
                                                         ass.Product2.Engine__c = plValue.getLabel();
                                                     }
                                                 }
                                             }
                                             availableAssetList.addAll(assetProductMap.get(pbEntry.Product2Id));
                                         }         
                                         
                                     }
        return availableAssetList;
    }
    
    public static List<Asset> getAssetListKR(String opportunityId, String modelId, String productId) {
        Boolean hasAssetAllocationPermission = FeatureManagement.checkPermission('KR_Allow_Asset_Allocation_to_Opportunity');
        String brand = '';   
        String modalName = '';
        Map<Id, Asset> assetMap;
        Opportunity presentOppRecord = [SELECT Id, Name, Pricebook2Id, Purchase_Type__c, Asset__c, Primary_Model_Interest__c, Primary_Model_Interest__r.Name, Brand__c, CurrencyISOCode FROM Opportunity where Id =:opportunityId];

    //updated for user story --- This is updated Korea market where user would need to see all the 
    //assets that belong to retailer
        

        if(productId != null && productId != '' && productId != 'none') {
            if(presentOppRecord.Purchase_Type__c == 'Used Vehicle') {
                assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                               Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                               Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                                               Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c,Product2.Alternative_Name__c,Product2.Description,Product2.Engine_Variant__c
                                               FROM Asset 
                                               WHERE Product2Id = :productId 
                                               AND RecordTypeId = :assetVehcileRecordTypeId
                                               //AND AccountId = :loggedInUser.AccountId 
                                               AND New_or_Used__c = 'Used' 
                                               AND Status = 'For Sale' 
                                              ]);
            }
            else {
                if(hasAssetAllocationPermission == false) {
                    return new List<Asset>();
                } else 
                {
                system.debug('@@@inserted else4 ');
                
                assetMap = new Map<Id, Asset>([
                    SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                    Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                    Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                    Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c,Product2.Alternative_Name__c,Product2.Description,Product2.Engine_Variant__c
                    FROM Asset 
                    WHERE Product2Id = :productId 
                    AND RecordTypeId =  :assetVehcileRecordTypeId
                    //AND AccountId = :loggedInUser.AccountId  
                    AND (New_or_Used__c = null OR New_or_Used__c != 'Used') 
                ]);
                
                }
            }
        }
        else {
            system.debug('@@@inserted else5 ');
            if(modelId != null && modelId != '' && modelId != 'none') {
                system.debug('@@@inserted else6 ');
                Vehicle_Specification__c primaryIntrestModel = [SELECT Id, Make__c, Name FROM Vehicle_Specification__c WHERE Id=:modelId];
                brand = primaryIntrestModel.make__c;
                modalName = primaryIntrestModel.Name;
            } else {
                system.debug('@@@inserted else7 ');
                brand = presentOppRecord.Brand__c;            
                modalName = presentOppRecord.Primary_Model_Interest__r.Name;
            }
            
            if(presentOppRecord.Purchase_Type__c == 'Used Vehicle') {
                system.debug('@@@inserted else8 ');
                assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                            Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                            Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c,  
                                            Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c,Product2.Alternative_Name__c,Product2.Description,Product2.Engine_Variant__c
                                            FROM Asset 
                                            WHERE Brand__c = :brand 
                                            AND RecordTypeId =  :assetVehcileRecordTypeId
                                            //AND AccountId = :loggedInUser.AccountId
                                            AND New_or_Used__c = 'Used' 
                                            AND Status = 'For Sale' 
                                            AND Product2Id != null
                                            AND Product2.Model_Alternative__c = :modalName]);
            } else {
                
                
                if(hasAssetAllocationPermission == false) {
                    return new List<Asset>();
                } else {
                    system.debug('@@@inserted else11 ');
                    system.debug('@@@profile name ' + loggedInUser.profile.NAME);
                    system.debug('@@@country iso code ' + loggedInUser.Country_ISO_Code__c);
                    // if(loggedInUser.profile.Name !=null && loggedInUser.Country_ISO_Code__c !=null){
                    //  system.debug('@@@inserted else12 ');
                    
                    system.debug('@@@profile name ' + loggedInUser.profile.NAME);
                    system.debug('@@@country iso code ' + loggedInUser.Country_ISO_Code__c);
                    assetMap = new Map<Id, Asset>([SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                                Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, Product2.Model_Year__c, 
                                                Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, Registration_Number__c, Product2.Engine_Type__c, 
                                                Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, Model_Alternative__c, New_or_Used__c,Product2.Alternative_Name__c,Product2.Description,Product2.Engine_Variant__c
                                                FROM Asset 
                                                WHERE Brand__c = :brand 
                                                AND RecordTypeId =  :assetVehcileRecordTypeId
                                                //AND AccountId = :loggedInUser.AccountId
                                                AND (New_or_Used__c = null OR New_or_Used__c != 'Used') 
                                                AND Product2Id != null
                                                AND Product2.Model_Alternative__c = :modalName]);
                    system.debug('@@@inserted else13KR ');
                    system.debug(assetMap);
            
                }
            }


            if(!assetMap.isEmpty()){
            for(OpportunityLineItem oppLItem: [SELECT Id, Asset__c, Product2Id FROM OpportunityLineItem WHERE Asset__c IN :assetMap.values()]) {
                if(oppLItem !=null){
                if(assetMap.containsKey(oppLItem.Asset__c)) assetMap.remove(oppLItem.Asset__c);
                }
                    system.debug('@@@inserted else14KR ');
                    system.debug(assetMap);
            }
        }
    }  

    Map<Id, List<Asset>> assetProductMap = new Map<Id, list<Asset>>();
    for(Asset singleAsset : assetMap.values()) { 
        if(! assetProductMap.containsKey(singleAsset.Product2Id)) assetProductMap.put(singleAsset.Product2Id, new List<Asset>());
        assetProductMap.get(singleAsset.Product2Id).add(singleAsset);
    }

    List<Asset> availableAssetList = new List<Asset>();
    // availableAssetList.clear();
    for(PricebookEntry pbEntry: [SELECT Id, Product2Id 
                                    FROM PricebookEntry 
                                    WHERE Pricebook2Id =:presentOppRecord.Pricebook2Id 
                                    AND Product2Id IN :assetProductMap.keyset()
                                    AND CurrencyIsoCode = :presentOppRecord.CurrencyIsoCode 
                                    AND Pricebook2.IsActive = true 
                                    AND IsActive = true]) {
                                        
        if(assetProductMap.containsKey(pbEntry.Product2Id)) {
            List<Asset> assetsToAdd = assetProductMap.get(pbEntry.Product2Id);
            Schema.SObjectType assetType = Schema.getGlobalDescribe().get('Asset');
            Schema.DescribeSObjectResult assetResult = assetType.getDescribe();
            Schema.DescribeFieldResult engineField = assetResult.fields.getMap().get('Engine__c').getDescribe();
            for(Asset ass : assetProductMap.get(pbEntry.Product2Id)) {
                for(Schema.PicklistEntry plValue : engineField.getPicklistValues()) {
                    System.debug('plValue: ' + plValue + ' - Engine: ' + ass.Product2.Engine__c);
                    if(plValue.getValue() == ass.Product2.Engine__c) {
                        ass.Product2.Engine__c = plValue.getLabel();
                    }
                }
            }
            availableAssetList.addAll(assetProductMap.get(pbEntry.Product2Id));
        }         
        
    }

    System.debug('available Asset Lists');
    System.debug(JSON.serializePretty(availableAssetList));
    return availableAssetList;
    }

    // CXPD-1659 - MENA || Vehicle Selection || Error Message on Missing Pricebook 
    public class CustomException extends Exception {}
    
    @AuraEnabled
    public static OpportunityLineItem getLineItem(String opportunityId, String assetId, String modelId, String productId) {      
        
        Asset selectedAsset = [SELECT Id, Name, VIN__c, Vehicle_ID__c, Product2Id, Brand__c, Price, Quantity, Order_Number__c, Model_Alternative__c FROM Asset WHERE Id =:assetId]; 
        
        Opportunity presentOppRecord = [SELECT Id, Name, Pricebook2Id, Asset__c, Primary_Model_Interest__c, Brand__c, CurrencyISOCode FROM Opportunity WHERE Id =:opportunityId];        
        presentOppRecord.Brand__c = selectedAsset.Brand__c;
        presentOppRecord.Primary_Model_Interest__c = modelId;            
        //update presentOppRecord;
        
        try {
            PricebookEntry pbEntry = [SELECT Id, Product2Id, UnitPrice 
                                      FROM PricebookEntry 
                                      WHERE Pricebook2Id =:presentOppRecord.Pricebook2Id 
                                      AND Product2Id = :selectedAsset.Product2Id
                                      AND CurrencyIsoCode = :presentOppRecord.CurrencyISOCode 
                                      LIMIT 1];
            
            return new OpportunityLineItem(Asset__c = selectedAsset.Id, 
                                           Product2Id = selectedAsset.Product2Id, 
                                           Brand__c = selectedAsset.Brand__c, 
                                           OpportunityId = opportunityId, 
                                           QUANTITY = 1, 
                                           UnitPrice = pbEntry.UnitPrice, 
                                           PricebookEntryId = pbEntry.Id, 
                                           Status__c='Fulfilled From Stock');
        } catch(QueryException queryEx) {
            throw new CustomException('Please select the pricebook on opportunity.');
        } catch(Exception ex) {
            throw new CustomException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String createOppProduct(String opportunityId, String productId, String modelId, String assetId) {
        String message = '';
        try{
            //if the Opportunity already has an Opportunity Product, edit it, otherwise create it
            OpportunityLineItem oli = new OpportunityLineItem();
            List<OpportunityLineItem> oliList = [SELECT Id, OpportunityId, Product2Id, Asset__c FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
            System.debug('Got existing olis: ' + oliList);
            if(oliList.size() > 0) {
                // oli = oliList[0];
                delete oliList;
                System.debug('Deleting olis');
            }
            //User loggedInUser = [SELECT Id, AccountId, Contact.AccountId, Contact.Country_ISO_Code__c, CurrencyIsoCode, DefaultCurrencyIsoCode FROM User WHERE Id = :userinfo.getUserId() AND ContactId != null AND AccountId != null];
            Opportunity opp = [SELECT Id, Pricebook2Id, CurrencyISOCode FROM Opportunity WHERE Id = :opportunityId];
            System.debug('Got opp: ' + opp);
            PricebookEntry pricebookProd = [SELECT Id, UnitPrice, CurrencyIsoCode 
                                            FROM PricebookEntry 
                                            WHERE Pricebook2Id = :opp.Pricebook2Id 
                                            AND CurrencyIsoCode = :opp.CurrencyIsoCode 
                                            AND Pricebook2.IsActive = true 
                                            AND Product2Id = :productId 
                                            AND IsActive = true LIMIT 1];
            System.debug('Got pricebook entry: ' + pricebookProd);
            oli.Product2Id = productId;
            oli.OpportunityId = opportunityId;
            oli.Quantity = 1; // Set default quantity to 1
            oli.Asset__c = null;
            oli.UnitPrice = pricebookProd.UnitPrice;
            oli.PricebookEntryId = pricebookProd.Id;
            System.debug('Upserting oli: ' + oli);
            upsert oli;
            
            //need to also update the Opportunity's Primary Model of Interest in case this has changed
            System.debug('Updating opp ' + OpportunityId + ' with ' + modelId);
            updateOpportunity(OpportunityId, assetId, modelId, productId);
            //  update new Opportunity(Id=OpportunityId, Primary_Model_Interest__c=modelId);
            System.debug('Finished');
            message = 'Success';
        } catch(Exception e) {
            message = e.getMessage();
            System.debug('ERROR: ' + message);
        }
        return message;
    }
    
    @AuraEnabled
    public static String saveProductLineItem(OpportunityLineItem oppLineItem,  String opportunityId,  String assetId,  String modelId,  String productId) {      
        String message = '';
        try {
            OpportunityLineItem upsertedLineItem = oppLineItem;
            
            Asset selectedAsset = [SELECT Id, Name, VIN__c, Vehicle_ID__c, Product2Id, Brand__c, Price, Quantity, Order_Number__c, Model_Alternative__c FROM Asset WHERE Id =:assetId];
            
            Opportunity presentOppRecord = [SELECT Id, Name, Pricebook2Id, Asset__c, Primary_Model_Interest__c, Brand__c, (SELECT Id, Asset__c, Product2Id FROM OpportunityLineItems LIMIT 1) FROM Opportunity WHERE Id =:opportunityId];  
            
            if(presentOppRecord.OpportunityLineItems.size() > 0 && presentOppRecord.OpportunityLineItems[0].Product2Id != selectedAsset.Product2Id) {
                upsertedLineItem = oppLineItem.clone(false, false, false, false);
                delete presentOppRecord.OpportunityLineItems[0];
            } 
            else if(presentOppRecord.OpportunityLineItems.size() > 0 && presentOppRecord.OpportunityLineItems[0].Product2Id == selectedAsset.Product2Id) {
                upsertedLineItem.Id = presentOppRecord.OpportunityLineItems[0].Id;
                upsertedLineItem.Asset__c = assetId;
            }
            system.debug('upsertedLineItem' + upsertedLineItem);
            presentOppRecord.Brand__c = selectedAsset.Brand__c;
            presentOppRecord.Primary_Model_Interest__c = modelId;            
            update presentOppRecord;
            upsert upsertedLineItem; 
            message = 'Success';
        } catch(Exception e) {
            message = e.getMessage();
        }
        return message;
    }
    
    @AuraEnabled
    public static String updateOpportunity(String opportunityId, String assetId, String modelId, String productId) {      
        String message = '';
        try{
            if(assetId != null && assetId != '') {
                Asset selectedAsset = [SELECT Id, Interior_Color__c, Exterior_Colour__c, Model_Year__c, Product2.Specification_Pack_Alternative__c, Power_Output_Value__c, VIN__c, Brand__c, 
                                       Body_Style__c, Fuel_Type__c, Product2.Engine_Capacity_Alternative__c, Engine__c, Wheel_Base__c, Wheels_Driven__c, Product2.Transmission__c, Order_Number__c,                                   
                                       Model_Alternative__c FROM Asset WHERE Id=:assetId LIMIT 1];
                
                update new Opportunity(Id=opportunityId, Model_Year__c = selectedAsset.Model_Year__c,  Specification__c = selectedAsset.Product2.Specification_Pack_Alternative__c, 
                                       Transmission__c = selectedAsset.Product2.Transmission__c, Engine__c = selectedAsset.Engine__c, Wheel_Base__c = selectedAsset.Wheel_Base__c, 
                                       Engine_Capacity__c = selectedAsset.Product2.Engine_Capacity_Alternative__c, Wheels_Driven__c = selectedAsset.Wheels_Driven__c,   
                                       Fuel_Type__c = selectedAsset.Fuel_Type__c, Exterior_Colour__c = selectedAsset.Exterior_Colour__c, Body_Style__c = selectedAsset.Body_Style__c, 
                                       Interior_Colour__c = selectedAsset.Interior_Color__c, Power__c = selectedAsset.Power_Output_Value__c, VIN__c= selectedAsset.VIN__c, 
                                       Is_Defer_Decision__c = true, Brand__c = selectedAsset.Brand__c, Primary_Model_Interest__c = modelId); 
                message = 'Success';
            }
            else if(productId != null && productId != '') {
                Product2 prod = [SELECT Id, Name, Model_Year__c, Specification_Pack_Alternative__c, Transmission__c, 
                                 Engine__c, Wheel_Base__c, Engine_Capacity_Alternative__c, Wheel_Driven__c, 
                                 Fuel_Type_Alternative__c, Body_Style__c, Power_Output_Alternative__c, Make__c
                                 FROM Product2 WHERE Id = :productId];
                
                update new Opportunity(Id=opportunityId, Model_Year__c=prod.Model_Year__c, Specification__c=prod.Specification_Pack_Alternative__c, 
                                       Transmission__c=prod.Transmission__c, Engine__c=prod.Engine__c, Wheel_Base__c=prod.Wheel_Base__c, 
                                       Engine_Capacity__c=prod.Engine_Capacity_Alternative__c, Wheels_Driven__c=prod.Wheel_Driven__c, 
                                       Fuel_Type__c=prod.Fuel_Type_Alternative__c, Body_Style__c=prod.Body_Style__c, 
                                       Power__c=prod.Power_Output_Alternative__c, Is_Defer_Decision__c=true, Brand__c=prod.Make__c, 
                                       Primary_Model_Interest__c = modelId);
                message = 'Success';
            }
        } catch(Exception e) {
            message = e.getMessage();
        }
        return message;
    }
    
    @AuraEnabled
    public static List<Map<String, String>> getFilteredListOfProducts(List<Map<String, String>> peList, String filterString) {
        if(filterString != null && filterString.trim().length() > 0) {
            List<String> parts = filterString.split(' ');
            List<Map<String, String>> filteredList = new List<Map<String, String>>();
            if(parts != null && parts.size() > 0) {
                for(Map<String, String> pe : peList) {
                    if(pe != null && pe.containsKey('filter_label')) {
                        String prodName = pe.get('filter_label');
                        boolean prodMatch = true;
                        for(String filterPart : parts) {
                            if(prodName.indexOfIgnoreCase(filterPart) < 0 ) {
                                prodMatch = false;
                            }
                        }
                        if(prodMatch) {
                            filteredList.add(pe);
                        }
                    }
                }
                return filteredList;
            }
        }
        return peList;
    }
    
    private static Map<Id, List<Asset>> getProductAssetMap(Set<Id> prodIds, boolean isUsed) {
        //(NOT Status = 'For Sale') AND (NOT New_or_Used__c = 'Used')
        Map<Id, List<Asset>> assetMap = new Map<Id, List<Asset>>();
        if(isUsed) {
            for(Asset ass : [SELECT Id, Product2Id FROM Asset 
                             WHERE Product2Id IN :prodIds 
                             AND AccountId =:loggedInUser.AccountId 
                             AND Status = 'For Sale' 
                             AND New_or_Used__c = 'Used']) {
                                 if(!assetMap.containsKey(ass.Product2Id)) {
                                     assetMap.put(ass.Product2Id, new List<Asset>());
                                 }
                                 assetMap.get(ass.Product2Id).add(ass);
                             }
        } else {
            // Only Applicable for New Vehicle as per CXPD-1696 (Removed Status check for Non-MENA Market)
            if(loggedInUser.Market__c == 'MENA') {
                for(Asset ass : [SELECT Id, Product2Id FROM Asset 
                                 WHERE Product2Id IN :prodIds 
                                 AND AccountId =:loggedInUser.AccountId 
                                 AND Status IN :AssetStatusList 
                                 AND Common_Sale_Type__c IN :AssetCommonSaleTypeList 
                                 AND (New_or_Used__c = null OR New_or_Used__c  != 'Used')]) {
                                     if(!assetMap.containsKey(ass.Product2Id)) {
                                         assetMap.put(ass.Product2Id, new List<Asset>());
                                     }
                                     assetMap.get(ass.Product2Id).add(ass);
                                 }
            } else {
                for(Asset ass : [SELECT Id, Product2Id FROM Asset 
                                 WHERE Product2Id IN :prodIds 
                                 AND AccountId =:loggedInUser.AccountId 
                                 AND (New_or_Used__c = null OR New_or_Used__c  != 'Used')]) {
                                     if(!assetMap.containsKey(ass.Product2Id)) {
                                         assetMap.put(ass.Product2Id, new List<Asset>());
                                     }
                                     assetMap.get(ass.Product2Id).add(ass);
                                 }
            }
        }
        return assetMap;
    }
    
    //1.0
    @AuraEnabled
    public static List<Asset> getAssetListUsingVIN(String vinNumber) {

        if(loggedInUser.Market__c == 'Korea') {
            Boolean hasAssetAllocationPermission = FeatureManagement.checkPermission('KR_Allow_Asset_Allocation_to_Opportunity');
            //Opportunity presentOppRecord = [SELECT Id, Name, Pricebook2Id, Purchase_Type__c, Asset__c, Primary_Model_Interest__c, Primary_Model_Interest__r.Name, Brand__c, CurrencyISOCode FROM Opportunity where Id =:opportunityId];
            if(!hasAssetAllocationPermission) {
                return new List<Asset>();
            }
        }
        List<Asset> lstAssets = [SELECT Id, Name, Product2Id, VIN__c, Vehicle_ID__c, Product2.Make__r.Name, Product2.Model_Alternative__c, Product2.ProductCode, 
                                 Product2.Model_Year_Alternative__c, Product2.Specification_Pack_Alternative__c, Product2.Engine__c, Product2.Wheel_Base__c, 
                                 Product2.Model_Year__c, Product2.Body_Style__c, Product2.Transmission__c, Exterior_Colour__c, Interior_Color__c, 
                                 Registration_Number__c, Product2.Engine_Type__c, Product2.Product_Description__c, Product2.Model__r.ProductCode, Order_Number__c, 
                                 Model_Alternative__c, New_or_Used__c FROM Asset 
                                 WHERE (VIN__c =:vinNumber OR Order_Number__c =:vinNumber)];
        return lstAssets;
    }
    //1.0
    @AuraEnabled
    public static AccountOpptyWrapper getRelatedAccAndOppty(String assetId) {
        AccountOpptyWrapper objAccountOpptyWrapper = new AccountOpptyWrapper();
        List<OpportunityWrapper> opportunityWrapperList = new List<OpportunityWrapper>();
        Map<Id, Opportunity> relatedOpptyMap = new Map<Id, Opportunity>();
        Map<Id, String> oppIdToAssetMap = new Map<Id, String>();
        Asset selectedAsset = [SELECT Id, AccountId FROM Asset WHERE Id =:assetId];
        
        if(String.isNotBlank(selectedAsset.AccountId)) {
            List<Account> relatedAccount = new List<Account>();
            relatedAccount = [SELECT Id, Name, FirstName, LastName, Record_Type_Name__c, PersonEmail, PersonMobilePhone, Phone, CreatedBy.Name, CreatedDate, 
                              (Select Id, Name, Account.Name, CreatedBy.Name, CreatedDate, Primary_Model_Interest__c FROM Opportunities)
                              FROM Account WHERE Id =:selectedAsset.AccountId LIMIT 1];
            objAccountOpptyWrapper.relatedAccount = relatedAccount;
            
            List < Account > potentialDuplicateAccount = [SELECT Id, Name, FirstName, LastName, Record_Type_Name__c, PersonEmail, PersonMobilePhone, Phone, CreatedBy.Name, CreatedDate 
                                                          FROM Account 
                                                          WHERE RecordType.DeveloperName = 'Individual' 
                                                          And LastName = :relatedAccount[0].LastName 
                                                          And (PersonEmail = :relatedAccount[0].PersonEmail
                                                               Or PersonMobilePhone = :relatedAccount[0].PersonMobilePhone
                                                               Or Phone = :relatedAccount[0].Phone)]; 
            objAccountOpptyWrapper.potentialDuplicateAccount = potentialDuplicateAccount;
            
            for(Opportunity objOppty : relatedAccount[0].Opportunities) {
                relatedOpptyMap.put(objOppty.Id, objOppty);
            }
            
            for(OpportunityLineItem objOpptyLine : [SELECT Id, Asset__r.VIN__c, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN:relatedOpptyMap.keyset()]) {
                if(!oppIdToAssetMap.containsKey(objOpptyLine.OpportunityId)) {
                    oppIdToAssetMap.put(objOpptyLine.OpportunityId, objOpptyLine.Asset__r.VIN__c);
                }
            }
            
            for(Id oppId : relatedOpptyMap.keySet()) {
                OpportunityWrapper objOpportunityWrapper = new OpportunityWrapper();
                objOpportunityWrapper.opptyId = oppId;
                objOpportunityWrapper.opptyName = relatedOpptyMap.get(oppId).Name;
                objOpportunityWrapper.opptyAccName = relatedOpptyMap.get(oppId).Account.Name;
                objOpportunityWrapper.opptyCreatedBy = relatedOpptyMap.get(oppId).CreatedBy.Name;
                objOpportunityWrapper.opptyCreatedDate = relatedOpptyMap.get(oppId).CreatedDate;
                objOpportunityWrapper.opptyPrimaryModelInt = relatedOpptyMap.get(oppId).Primary_Model_Interest__c;
                objOpportunityWrapper.opptyLineItemAsset = oppIdToAssetMap.get(oppId);
                opportunityWrapperList.add(objOpportunityWrapper);
            }
            objAccountOpptyWrapper.relatedOpptyList = opportunityWrapperList;
        }
        return objAccountOpptyWrapper;
    }
    
    // CXPD-1455
    @AuraEnabled
    public static String sendAccountsForReview(List < Account > accountList) {
        System.debug('### accountList ' + accountList);
        String message = '';
        Set < Market_Email_Setting__mdt > recepientSet = new Set < Market_Email_Setting__mdt > ();
        if(String.isNotBlank(loggedInUser.Country_ISO_Code__c)) {
            for(Market_Email_Setting__mdt temp: [SELECT Id, DeveloperName, Email__c, Country__c, Market__c 
                                                 FROM Market_Email_Setting__mdt 
                                                 WHERE IsActive__c = true 
                                                 AND Country__c = :loggedInUser.Country_ISO_Code__c]) {
                                                     recepientSet.add(temp);
                                                 }
        }
        if(String.isNotBlank(loggedInUser.Market__c)) {
            for(Market_Email_Setting__mdt temp: [SELECT Id, DeveloperName, Email__c, Country__c, Market__c 
                                                 FROM Market_Email_Setting__mdt 
                                                 WHERE IsActive__c = true 
                                                 AND Market__c = :loggedInUser.Market__c]) {
                                                     recepientSet.add(temp);
                                                 }
        }
        if(recepientSet.isEmpty()) {
            message = 'No Recepients found to review these duplicate accounts. Please contact System administrator.';
            return message;
        }
        if(accountList == null || accountList.isEmpty()) {
            message = 'No Accounts for Review found. Please contact System administrator.';
            return message;
        }
        try {
            
            // Prepare list of email addresses
            Set < String > emailAddresses = new Set < String > ();
            for(Market_Email_Setting__mdt temp: recepientSet) {
                emailAddresses.add(temp.Email__c);
            }
            
            Review_Duplicate_Account_Email__c obj = new Review_Duplicate_Account_Email__c();
            obj.Email_Actioned_User__c = loggedInUser.Id;
            obj.Market__c = loggedInUser.Market__c;
            obj.Country__c = loggedInUser.Country_ISO_Code__c;
            obj.Email_Body__c = JSON.serializePretty(accountList); 
            obj.Recepient_Email_Address__c = JSON.serializePretty(emailAddresses);
            
            insert obj;
        } catch(Exception ex) {
            message = ex.getMessage();
        }
        return message;
    }
    
    
    
    public class AccountOpptyWrapper {
        @AuraEnabled public List<Account> relatedAccount {get; set;}
        @AuraEnabled public List<Account> potentialDuplicateAccount {get; set;}
        @AuraEnabled public List<OpportunityWrapper> relatedOpptyList {get; set;}
    }
    
    public class OpportunityWrapper {
        @AuraEnabled public Id opptyId {get; set;}
        @AuraEnabled public String opptyName {get; set;}
        @AuraEnabled public String opptyAccName {get; set;}
        @AuraEnabled public String opptyCreatedBy {get; set;}
        @AuraEnabled public DateTime opptyCreatedDate {get; set;}
        @AuraEnabled public String opptyPrimaryModelInt {get; set;}
        @AuraEnabled public String opptyLineItemAsset {get; set;}
    }

    //CXPD-2223
    @AuraEnabled
    public static String getregionmarket() {    
        system.debug('inside getregionmarket method');
        Id useridinfo = UserInfo.getUserId();
        List<User> regionmarket = [Select Name,Market__c from User where Id =: useridinfo]; 
        system.debug('inside getregionmarket method'+regionmarket[0].Market__c);
        return regionmarket[0].Market__c;  
    }
}